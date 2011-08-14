class Admin::PagesController < ApplicationController
  before_filter :get_routes, :except => [:index, :destroy]
  layout 'admin'
  
  def index
    @pages = Page.all.group_by(&:parent_id)

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
    Page.page_parts.collect { |page_part| @page.page_parts.build(:title => page_part) }
    @parent = Page.find_by_permalink(params[:page_id])
    @roles = Extras.class_exists?('Role') ? Role.all : []

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/1/edit
  def edit
    @page = Page.includes([:parent, :page_parts]).where({ :permalink => params[:id] })
    @page = @page.includes(:required_roles) if defined?(Role)
    @page = @page.first
    @parent = @page.parent
    @roles = Extras.class_exists?('Role') ? Role.all : []
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
        @roles = Extras.class_exists?('Role') ? Role.all : []
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    @page = Page.includes([:parent, :page_parts]).find(params[:the_page_id])    

    if Extras.class_exists?('Role')
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
        @roles = Extras.class_exists?('Role') ? Role.all : []
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
      format.html { redirect_to(admin_pages_path) }
      format.xml  { head :ok }
      format.js { @pages = Page.all.group_by(&:parent_id) }
    end
  end


  def sort
    @drag = Page.find_by_id(params[:id])
    @drop = Page.find_by_id(params[:position_id]).self_and_descendants

    begin
      case params[:position]
        when "before"
          @drag.move_to_left_of @drop.first
        when "after"
          @drag.move_to_right_of @drop.first
        when "child"
          @drag.move_to_child_of @drop.first
      end
      flash[:notice] = "Move was successful"
    rescue Exception => exc
      @error = exc.message
      flash.delete(:notice)
      flash[:alert] = "Move failure: #{@error}"
    end

    @pages = Page.all.group_by(&:parent_id)

    respond_to do |format|
      format.js
    end
  end

  def duplicate
    @original_page = Page.find_by_permalink params[:id], :include => [:page_parts]
    @page = @original_page.duplicate
    @pages = {}
    
    flash[:notice] = 'Page was successfully duplicated'

    respond_to do |format|
      format.html { redirect_to admin_pages_path }
      format.js
    end
  end

  private

    # Retrieve the available routes (:get only) and compile the ones already taken by other pages
    def get_routes
      @current = Page.just_controller_and_actions.collect{|i| i.taken }.compact
      @routes = Cmser::RoutesFinder.available
    end
end

