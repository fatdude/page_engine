require 'page_engine/defaults'
require "page_engine/engine"
require 'page_engine/extensions'
require 'page_engine/helpers'
require 'RedCloth'
require 'bluecloth'
require 'haml'
require 'simple_form'
require 'awesome_nested_set'

module PageEngine
  
  # The list of layouts available to the pages
  mattr_accessor :layouts
  @@layouts = ['application']
  
  # The page parts that are created with a new page
  mattr_accessor :page_parts
  @@page_parts = %w{ body left right header footer }
  
  # Extra page statuses added to the default values
  @@statuses = %w{ Draft Published Review Hidden }
  
  # List of filters that can be applied
  mattr_accessor :filters
  @@filters = %w{ none html textile markdown erb erb+textile }
  
  # List of actions that should be included when getting the available routes
  mattr_accessor :required_route_actions
  @@required_route_actions = %w{ index show new edit create update }
  
  # List of controllers that should be excluded when getting the available routes
  mattr_accessor :excluded_route_controllers
  @@excluded_route_controllers = []
  
  # To give more control over which controllers are returned
  mattr_accessor :excluded_route_controllers_regex
  @@excluded_route_controllers_regex = /^admin.*/
  
  # If the page should be only viewable by a specific role, set the role class here
  mattr_accessor :role_class
  @@role_class = 'Role'
  
  # The author class
  mattr_accessor :author_class
  @@author_class = 'User'
  
  # Set the helper method that will be used to get the current author
  mattr_accessor :current_author_helper
  @@author_class = 'current_user'
  
  # Set the helper method that will be used to get the current user
  mattr_accessor :current_viewer_helper
  @@current_viewer_helper = 'current_user'

  # Module methods
  
  def self.statuses=s
    @@statuses += s if s.is_a?(Array)
  end  
  
  def self.statuses
    @@statuses
  end
  
  def self.class_exists?(class_name)
    klass = Module.const_get(class_name)
    return klass.is_a?(Class)
    rescue NameError
      return false
  end
  
  def self.available_routes(options = {})
    options = {
      :required_actions => @@required_route_actions,
      :excluded_controllers => @@excluded_route_controllers,
      :excluded_controller_regex => @@excluded_route_controllers_regex
    }.merge!(options.symbolize_keys)
    
    available = {}
    
    controller_actions = Rails.application.routes.routes.map(&:requirements)
    
    controller_actions.delete_if { |c| c.empty? || c[:controller] == 'rails/info' || c[:controller] == 'pages' || !options[:required_actions].include?(c[:action]) || options[:excluded_controllers].include?(c[:controller]) || c[:controller] =~ options[:excluded_controller_regex] }
    
    controller_actions.each do |c|
      available[c[:controller]] ||= []
      available[c[:controller]] << c[:action]
    end
    
    available
  end
  
  def self.setup
    yield self
  end   
  
  def self.uses_roles?
    !self.role_class.blank?
  end
  
  def self.has_author?
    !self.author_class.blank?
  end
  
  def self.has_viewers?
    !self.current_viewer_helper.blank?
  end
 
end

ActionView::Helpers::AssetTagHelper.register_javascript_expansion :page_engine => ["jquery-ui-1.8.15.custom.min", "jquery.ui.nestedSortable", "jquery.markitup", "markitup/sets/html/set", "markitup/sets/textile/set", "markitup/sets/markdown/set", "codemirror/codemirror", "codemirror/modes/javascript", "codemirror/modes/css", "page_engine"]
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :page_engine => ["jquery-ui", "markitup/skins/simple/style", "markitup/sets/html/style", "markitup/sets/textile/style", "markitup/sets/markdown/style", "codemirror/codemirror", "codemirror/themes/default", "page_engine"]
