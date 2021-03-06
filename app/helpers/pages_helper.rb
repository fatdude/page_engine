module PagesHelper  

  # Set the page title 
  def page_title(default_text)
    if @page
      replace_title_for(@page)
    else
      default_text
    end
  end
  
  def page_js(options={})
    options = {
      :with_tags => true
    }.with_indifferent_access.merge(options)
    
    if options[:with_tags]
      if @page && !@page.js.blank?
        javascript_tag do 
          @page.js
        end
      end
    else
      @page.js
    end
  end
  
  def page_css(options={})
    options = {
      :with_tags => true
    }.with_indifferent_access.merge(options)
  
    if options[:with_tags]
      if @page && !@page.css.blank?
        content_tag :style do
          @page.css
        end
      end
    else
      @page.css
    end
  end
  
  def page_meta_keywords(options={})
    options = {
      :with_tags => true
    }.with_indifferent_access.merge(options)
    
    if options[:with_tags]
      if @page && !@page.meta_keywords.blank?
        content_tag :meta, :name => 'keywords' do 
          @page.meta_keywords
        end
      end
    else
      @page.meta_keywords
    end
  end
  
  def page_meta_description(options={})
    options = {
      :with_tags => true
    }.with_indifferent_access.merge(options)
    
    if options[:with_tags]
      if @page && !@page.meta_description.blank?
        content_tag :meta, :name => 'description' do 
          @page.meta_description
        end
      end
    else
      @page.meta_description
    end
  end
  
  # Usage:
  # You can use the attributes of any instance variables and insert them in the title
  # For example:
  #   This is a page for {{my_object:my_object_attribute}}
  # Requires that any object that will be used have a public whitelist method which returns an array 
  # of legal attributes (as this can be set by a user certain attributes should not be exposed)
  def replace_title_for(page)
    return nil unless page
    page.title.scan(/\{\{(\w+):(\w+)\}\}/).uniq.flatten.in_groups_of(2).each do |klass, attribute|
      if self.instance_variable_defined? "@#{klass}"
        obj = self.instance_variable_get "@#{klass}"
        if obj.class.public_methods.include?(:whitelist) && obj.class.whitelist.is_a?(Array)
          if obj.class.whitelist.include?(attribute)
            page.title.gsub!("{{#{klass}:#{attribute}}}", obj.send(attribute).to_s)  
          else
            page.title.gsub!("{{#{klass}:#{attribute}}}", "'#{attribute}' not in whitelist for #{obj.class}")
          end 
        else
          page.title.gsub!("{{#{klass}:#{attribute}}}", "Whitelist not defined for #{obj.class}")
        end   
      else
        page.title.gsub!("{{#{klass}:#{attribute}}}", "Not found")     
      end 
    end
    
    page.title
  end
  
  def page_part_fields(f)
    fields = simple_fields_for(:page_parts, PagePart.new, :child_index => "new_page_parts") do |builder|
      safe_concat(render('page_part_fields', :f => builder))
    end
    fields
  end 
  
  # Return the specified page part content
  def page_content(options={})
    options = {
      :page => @page,
      :part => 'body'
    }.with_indifferent_access.merge(options)
    
    options[:page].page_parts.detect { |p| p.title == options[:part].to_s } if options[:page]
  end
  
  def page_snippet(name, options={})
    options = {
      :default_text => 'Page snippet not found',
      :tag => nil,
      :class => ['page_snippet'],
      :id => nil
    }.with_indifferent_access.merge(options)
  
    page_snippet = PageSnippet.find_by_name(name.to_s)
    
    if options[:tag]
      content_tag options[:tag], :class => options[:class], :id => options[:id] do 
        page_snippet ? page_snippet : options[:default_text]
      end
    else
      page_snippet ? page_snippet : options[:default_text]
    end
  end

  def link_to_page(page, options={})
    # Arbitrarily chosen url to take precedence over controller and action
    if page.url.blank?
      if page.controller.blank? && page.action.blank?
        link_to replace_title_for(page), "/#{page.permalink}", options
      else
        link_to replace_title_for(page), url_for(:controller => '/' + page.controller, :action => page.action), options
      end
    else
      link_to replace_title_for(page), page.url, options
    end
  end

  # Takes an array of pages which constitute the ancestors of the current page (page) and displays them in the requested format
  # Options:
  # * seperator: The text or character that will seperate the breadcrumbs. Defaults to " &raquo; "
  # * format: choices are "ul" or "inline". "ul" displays the breadcrumb links in an unordered list whilst "inline" displays them inline in a containing div. Defaults to "ul"
  def breadcrumbs(options={})
    options = {
      :breadcrumbs => @breadcrumbs,
      :page => @page,
      :seperator => ' &raquo; ',
      :format => :ul
    }.with_indifferent_access.merge(options)

    case options[:format]
      when :inline
        content_tag :div, :class => :breadcrumbs do
          links = options[:breadcrumbs].collect.with_index { |breadcrumb, i| link_to_page(breadcrumb, :class => "crumb_#{i}") + options[:seperator].html_safe }.join().html_safe
          links += content_tag(:span, replace_title_for(options[:page]), :class => 'current_page') if options[:page]
        end
        
      when :ul
        content_tag :ul, :class => :breadcrumbs do
          links = options[:breadcrumbs].collect.with_index { |breadcrumb, i| content_tag(:li, link_to_page(breadcrumb, :class => "crumb_#{i}")) }.join().html_safe
          links += content_tag(:li, replace_title_for(options[:page]), :class => 'current_page') if options[:page]
        end
        
      else
        'Please choose one of :inline or :ul as a format'
    end
  end

  # Options:
  # * root: The root of the navigation structure
  # * current: The current_page if not @page
  # * depth: The number of levels in the tree to traverse. Defaults to 2
  # * class: The class of the containing ul. Defaults to ""
  # * id: The id of the containing id. Defaults to ""
  # * link_current: Set to true if the current page should have a link. Defaults to false  
  def navigation(options={})
    options = {
      :root => nil,
      :current => @page,
      :class => 'nav', 
      :id => '',
      :include_root => false,
      :link_current => false,
      :depth => 2
    }.with_indifferent_access.merge(options)

    current_user = nil unless defined?(current_user)
    
    if options[:root].is_a?(NilClass)
      root_page = Page.published_or_hidden.viewable_by(current_user).root_only.first
    elsif options[:root].is_a?(Page)
      root_page = options[:root]
    elsif options[:root].is_a?(String)
      root_page = Page.published_or_hidden.viewable_by(current_user).where('pages.url = :root or pages.permalink = :root', :root => options[:root]).first
    elsif options[:root].is_a?(Hash)
      options[:root].stringify_keys!
      root_page = Page.published_or_hidden.viewable_by(current_user).where(:controller => options[:root][:controller], :action => options[:root][:action]).first
    else
      return "<p><em>Error:</em> Root must be a page, a permalink, a url or a hash containing the controller and action, got: #{root.class.to_s}.</p>".html_safe
    end
    
    return "<p><em>Error:</em> Root page not found: #{options[:root]}</p>".html_safe unless root_page

    grouped_pages = root_page.self_and_descendants.viewable_by(current_user).shown_in_menu.published.for_nav.group_by(&:parent_id)

    render 'pages/navigation', :options => options, :root_page => root_page, :grouped_pages => grouped_pages, :level => 1
  end

  private

    # To add a class to the root of the tree that the current page appears in
    def mark_as_root_of_current? page
      if page.root?
        page == @page
      else
        return true if @breadcrumbs.include?(page) || page == @page
      end
    end

    def page_menu_class page
      css_classes = []
      css_classes << page.menu_css_class unless page.menu_css_class.blank?
      css_classes << "selected" if mark_as_root_of_current?(page)
    end
end

