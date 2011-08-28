class Page < ActiveRecord::Base
  acts_as_nested_set

  # Relationships
#  has_many :descendants, :class_name => "Page", :conditions => proc { "pages.lft between #{self.send(:lft)} and #{self.send(:rgt)}" }
#  has_many :ancestors, :class_name => "Page", :conditions => proc { "(pages.lft <= #{self.send(:lft)} AND pages.rgt >= #{self.send(:rgt)}) AND (pages.id != #{self.send(:id)})" }, :foreign_key => false
  has_many :pages, :foreign_key => :parent_id
  has_many :page_parts, :dependent => :destroy
  
  if PageEngine.class_exists?('Role')
    has_many :page_roles
    has_many :required_roles, :through => :page_roles, :source => :required_role
    has_many :excluded_roles, :through => :page_roles, :source => :excluded_role
  end
  
  if PageEngine.class_exists?('Asset')
    has_assets
  end
  
  if PageEngine.class_exists?('User')
    belongs_to :user
  end
  
  accepts_nested_attributes_for :page_parts, :allow_destroy => true

  # Filters
  before_validation :set_permalink
  before_save :check_publish_window
  before_save :set_controller_and_action

  # Validations
  validates :title, :presence => true
  validates :permalink, :presence => true, :uniqueness => true, :format => { :with => /^[a-z0-9-]+$/, :message => "Must only contain lower case letters, numbers or hyphens" }
  validates :url, :uniqueness => true, :allow_nil => true, :allow_blank => true
  validates_associated :page_parts

  # Scopes
  scope :by_permalink, lambda { |permalink| where(:permalink => permalink) }
  scope :published, lambda { where(["(status = 'Published' and ? between publish_from and publish_to) or (status = 'Published' and publish_from is null and publish_to is null)", DateTime.now]) }
  scope :published_or_hidden, lambda { where(["(status = 'Published' and ? between publish_from and publish_to) or (status = 'Published' and publish_from is null and publish_to is null) or status = 'Hidden'", DateTime.now]) }
  scope :root_only, where(:parent_id => nil)
  scope :shown_in_sitemap, where({ :display_in_sitemap => true })
  scope :shown_in_menu, where({ :display_in_menu => true })
  scope :just_controller_and_actions, select("controller || '|' || action as taken").group('taken')
  scope :for_nav, select([:id, :title, :parent_id, :menu_css_class, :no_link, :url, :controller, :action, :permalink])

  attr_accessor :no_publish_window, :controller_action  

  def no_publish_window
    no_publish_window_set?
  end

  def controller_action
    if controller && action
      "#{controller}|#{action}"
    end
  end

  def no_publish_window_set?
    self.publish_from.nil? && self.publish_to.nil?
  end

  def published?
    if self.no_publish_window_set?
      self.status == "Published"
    else
      self.publish_from < DateTime.now && self.publish_to > DateTime.now && self.status == "Published"
    end
  end

  def to_param
    permalink
  end

  def is_child_of? page
    self.parent_id == page.id ? true : false
  end

  def is_parent_of? page
    self.id == page.parent_id ? true : false
  end

  def number_of_children
    (self.rgt - self.lft - 1) / 2
  end

  def duplicate
    page = Page.new(self.attributes)
    page.title += " (copy) #{Time.now.strftime('%Y%m%d_%H%M%S')}"
    page.permalink = page.permalink + "-copy-#{Time.now.strftime('%Y%m%d-%H%M%S')}"
    page.save
    page.move_to_right_of self

    # Duplicate each of the objects associated with the original
    # Page parts
    self.page_parts.each do |page_part|
      page.page_parts << page_part.duplicate
    end

    # Roles
    if PageEngine.class_exists?('Role')
      page.required_roles = self.required_roles 
      page.excluded_roles = self.excluded_roles
    end

    # Assets
    if PageEngine.class_exists?('Asset')
      self.attachables.each do |attachable|
        page.attachables << attachable.duplicate
      end
    end

    page
  end

  def is_viewable_by? user
    if PageEngine.class_exists?('Role')
      if PageEngine.class_exists?('User') && user
        return true if self.roles.length == 0
        self.role_ids.length != (self.role_ids - user.role_ids.uniq).length        
      else
        self.roles.length == 0
      end
    else
      true
    end
  end

  def move_children_to_parent
    self.children.each do |child|
      if self.parent
        child.move_to_child_of self.parent
      else
        child.move_to_root
      end
    end
    self.reload
  end

  def css_status
    return "live" if self.published?
    status.downcase
  end
  
  # Override the protected methods of awesome_nested_set so lft and rgt can be set
  def lft=(x)
    self[:lft] = x    
  end
  
  def rgt=(x)
    self[:rgt] = x
  end

  class << self
    attr_accessor :layouts
    
    def breadcrumbs_for user, url
      root = Page.published.viewable_by(user).find_by_url(url)
      root.nil? ? [] : root.self_and_ancestors
    end

    def status_values
      ["Draft", "Published", "Review", "Hidden"]
    end
    
    def default_layout
      Page.layouts.first
    end

    def filters
      %w{ none html textile markdown erb erb+textile }
    end

    def page_parts
      %w{ body left right header footer }
    end

    # Scopes

    def viewable_by(user)
      if PageEngine.class_exists?('Role') && PageEngine.class_exists?('User')
        if user
          # This is a bit of a kludge until I can figure out how to get it to work properly in a single sql query
          includes(:page_roles).where("pages.id in (?) or (page_roles.required_role_id is null and page_roles.excluded_role_id is null)", PageRole.viewable_page_ids_for(user))
        else
          includes(:page_roles).where({ 'page_roles.required_role_id' => nil })
        end
      else
        scoped
      end      
    end

    def with_roles roles
      if Extras.class_exists?('Role')
        includes(:roles).where([ "roles.id IN (?)", roles.join(',') ])
      else
        scoped
      end
    end

    def with_url request, params
      url = request.fullpath
      url.gsub!(/\?.*/, '') # Strip away anything after the ? as it's not needed

      where(["pages.permalink = ? or url = ? or (controller = ? and action = ?)", params[:permalink], url, params[:controller], params[:action]])
    end

  end

  private

    def set_permalink
      self.permalink = self[:permalink].blank? ? self.title.parameterize : self[:permalink].parameterize
      self.menu_css_class = self.permalink if self[:menu_css_class].blank?
    end

    def set_controller_and_action
      if @controller_action
        controller_and_action = @controller_action.split('|')
        self.controller = controller_and_action.first
        self.action = controller_and_action.last
      else
        self.controller = nil
        self.action = nil
      end
    end

    def check_publish_window
      if @no_publish_window == "1"
        self.publish_to = self.publish_from = nil
      end
    end
end

