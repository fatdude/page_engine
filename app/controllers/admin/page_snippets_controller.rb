class Admin::PageSnippetsController < ApplicationController  
  def index
    @page_snippets = PageSnippet.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @page_snippets }
    end
  end
  
  def new
    @page_snippet = PageSnippet.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @page_snippet }
    end
  end

  def edit
    @page_snippet = PageSnippet.find(params[:id])
  end

  def create
    @page_snippet = PageSnippet.new(params[:page_snippet])

    respond_to do |format|
      if @page_snippet.save
        format.html { redirect_to(admin_page_snippets_url, :notice => 'Page snippet was successfully created.') }
        format.xml  { render :xml => @page_snippet, :status => :created, :location => @page_snippet }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page_snippet.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @page_snippet = PageSnippet.find(params[:id])

    respond_to do |format|
      if @page_snippet.update_attributes(params[:page_snippet])
        format.html { redirect_to(admin_page_snippets_url, :notice => 'Page snippet was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page_snippet.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @page_snippet = PageSnippet.find(params[:id])
    @page_snippet.destroy

    respond_to do |format|
      format.html { redirect_to(admin_page_snippets_url) }
      format.xml  { head :ok }
      format.js
    end
  end
end
