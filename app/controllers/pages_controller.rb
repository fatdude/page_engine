class PagesController < ApplicationController

  def index
    # Find the first published root page
    @pages = Page.published.shown_in_sitemap.all.group_by(&:parent_id)
  end
  
  def show
    if @page
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @page }
      end
    else
      raise ActiveRecord::RecordNotFound
    end
  end

end

