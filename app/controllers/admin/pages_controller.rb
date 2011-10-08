class Admin::PagesController < ApplicationController
  before_filter :get_routes, :except => [:index, :destroy]
  
  def index
    @pages = Page.order(:lft).all.group_by(&:parent_id)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pages }
    end
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    @page = Page.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
    @page = Page.new
    PageEngine.page_parts.collect { |page_part| @page.page_parts.build(:title => page_part) }
    @parent = Page.find_by_permalink(params[:page_id])
    @roles = PageEngine.uses_roles? ? PageEngine.role_class.classify.constantize.all : []

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/1/edit
  def edit
    @page = Page.includes([:parent, :page_parts])
    @page = @page.includes([:required_roles, :excluded_roles]) if PageEngine.uses_roles?
    @page = @page.find_by_permalink(params[:id])
    @parent = @page.parent
    @roles = PageEngine.uses_roles? ? PageEngine.role_class.classify.constantize.all : []
  end

  # POST /pages
  # POST /pages.xml
  def create
    @parent = Page.find_by_permalink(params[:page_id])
    @page = Page.new(params[:page])

    respond_to do |format|
      if @page.save      
        
        @page.move_to_child_of @parent unless @parent.nil?      
        
        return_path = params.has_key?('continue') ? edit_admin_page_path(@page) : admin_pages_path

        format.html { redirect_to(return_path, :notice => 'Page was successfully created.') }
        format.xml  { render :xml => @page, :status => :created, :location => @page }
      else
        @roles = PageEngine.class_exists?('Role') ? Role.all : []
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    @page = Page.includes([:parent, :page_parts]).find(params[:the_page_id])    

    if PageEngine.class_exists?('Role')
      params[:page][:required_role_ids] ||= []    
      params[:page][:excluded_role_ids] ||= []
    end

    respond_to do |format|
      if @page.update_attributes(params[:page])
        return_path = params.has_key?('continue') ? edit_admin_page_path(@page) : admin_pages_path
        
        format.html { redirect_to(return_path, :notice => 'Page was successfully updated.') }
        format.xml  { head :ok }
      else
        @parent = @page.parent
        @roles = PageEngine.class_exists?('Role') ? Role.all : []
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @page = Page.find_by_permalink(params[:id])    
    @page.move_children_to_parent
    @page.destroy

    respond_to do |format|
      format.html do
        redirect_to(admin_pages_path)
      end
      format.xml  { head :ok }
      format.js do
        @pages = Page.order(:lft).all.group_by(&:parent_id)
      end
    end
  end


  def sort 
    params[:pages].values.each do |value|
      @page = Page.find_by_id(value[:item_id])
      parent_id = value[:parent_id] == 'root' ? nil : value[:parent_id]
      
      @page.parent_id = parent_id
      @page.lft = value[:left].to_i - 1
      @page.rgt = value[:right].to_i - 1
      @page.save
    end
    
    render :nothing => true
  end

  def duplicate
    @original_page = Page.find_by_permalink params[:id], :include => [:page_parts]
    @page = @original_page.duplicate
    @pages = {}

    respond_to do |format|
      format.html { redirect_to admin_pages_path, :notice => 'Page was successfully duplicated' }
      format.js
    end
  end
  
  def parse_content
    case params[:data_type]
      when 'textile'
        render :text => RedCloth.new(params[:data]).to_html
      when 'markdown'
        render :text => BlueCloth.new(params[:data]).to_html
      else    
        render :nothing => true
    end
  end

  private

    # Retrieve the available routes (:get only) and compile the ones already taken by other pages
    def get_routes
      @current = Page.just_controller_and_actions.collect{ |i| i.taken }.compact
      @routes = {}
      
      routes = PageEngine.available_routes
      
      routes.keys.each do |controller|
        @routes[controller.humanize] = routes[controller].collect { |action| ["#{controller.humanize}::#{action.humanize}", "#{controller}|#{action}"] }
      end
    end
end

