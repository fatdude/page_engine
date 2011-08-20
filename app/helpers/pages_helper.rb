module PagesHelper
  
  # Helper for layout files so that all relevant javascript files are loaded
  def cmser_admin_js
    ['admin/cms', 'ckeditor/ckeditor', 'ckeditor/adapters/jquery.js', 'textile-editor', 'textile-editor-config']
  end

  # Helper for layout files so that all relevant css files are loaded
  def cmser_admin_css
    ['admin/cms', 'textile-editor']
  end

  # Set the page title 
  def page_title(default_text)
    if @page
      replace_title_for(@page)
    else
      default_text
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
    
    h(page.title)
  end
  
  # Add extra fields for an object in a form, in this case page parts
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      safe_concat(render(association.to_s.singularize + "_fields", :f => builder))
    end
    
    link_to('Add', '#', :onclick => "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")", :class => 'icon add')
  end  
  
  # Return the specified page part content
  def page_content(options={})
    default_options = {
      'page' => @page,
      'part' => 'body'
    }.merge!(options.stringify_keys)
    
    default_options[:page].page_parts.detect { |p| p.title == default_options[:part].to_s } if default_options[:page]
  end
  
  def page_snippet(name, default="Page snippet not found")
    page_snippet = PageSnippet.find_by_name(name.to_s)
    page_snippet ? page_snippet : default
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
    default_options = {
      'breadcrumbs' => @breadcrumbs,
      'page' => @page,
      'seperator' => ' &raquo; ',
      'format' => 'ul'
    }.merge!(options.stringify_keys)

    case default_options['format'].to_s
      when 'inline'
        content_tag :div, :class => 'breadcrumbs' do
          links = default_options['breadcrumbs'].collect.with_index { |breadcrumb, i| link_to_page(breadcrumb, :class => "crumb_#{i}") + default_options['seperator'].html_safe }.join().html_safe
          links += content_tag(:span, replace_title_for(default_options['page']), :class => 'current_page') if default_options['page']
        end
        
      when 'ul'
        content_tag :ul, :class => 'breadcrumbs' do
          links = default_options['breadcrumbs'].collect.with_index { |breadcrumb, i| content_tag(:li, link_to_page(breadcrumb, :class => "crumb_#{i}")) }.join().html_safe
          links += content_tag(:li, replace_title_for(default_options['page']), :class => 'current_page') if default_options['page']
        end
        
      else
        'Please choose one of \'inline\' or \'ul\' as a format'
    end
  end

  # Options:
  # * current: The current_page if not @page
  # * depth: The number of levels in the tree to traverse. Defaults to 2
  # * class: The class of the containing ul. Defaults to ""
  # * id: The id of the containing id. Defaults to ""
  # * link_current: Set to true if the current page should have a link. Defaults to false
  def navigation(permalink, options={})
    default_options = {
      'current' => @page,
      'class' => 'nav', 
      'id' => '',
      'include_root' => false,
      'link_current' => false,
      'depth' => 2
    }.merge!(options.stringify_keys)
    
#    options[:depth] = (options[:depth].nil? || options[:depth] < 1) ? 2 : options[:depth] + 1

    root_page = Page.published_or_hidden.viewable_by(current_user).find_by_permalink(permalink.to_s)
    return "<p><em>Error:</em> Root page not found</p>" unless root_page

    grouped_pages = root_page.self_and_descendants.viewable_by(current_user).shown_in_menu.published.group_by(&:parent_id)

    html = "<ul class=\"#{options[:class]}\" id=\"#{options[:id]}\">\n"
      if default_options['include_root']
        html += "<li#{page_menu_class(root_page)}>#{root_page.no_link || (root_page == default_options['current'] && !default_options['link_current']) ? "<span>" + replace_title_for(root_page) + "</span>" : link_to_page(root_page)}"
      end
      html = build_nav_nodes(root_page, grouped_pages, html, 1, options)
    html += "</ul>\n"
    
    html.html_safe
  end
  
  def filter_select(target, options={})
    default_options = {
      'builder' => nil,
      'object' => nil,
      'attribute' => nil  
    }.merge!(options.stringify_keys)
    
    if default_options['builder']
      default_options['builder'].select(default_options['attribute'], Page.filters, {}, { :class => 'filter', :rel => target })
    else
      select_tag(default_options['object'], default_options['attribute'], Page.filters, {}, { :class => 'filter', :rel => target })
    end
  end

  private

    def build_nav_nodes root, grouped_pages, html, level, options={}
      grouped_pages[root.id] ||= []

      grouped_pages[root.id].each do |page|
        if level <= options[:depth]
          html += "<li#{page_menu_class page}>#{page.no_link || (page == options[:current] && !options[:link_current]) ? "<span>" + replace_title_for(page) + "</span>" : link_to_page(page)}"
          if grouped_pages.keys.include?(page.id)
            html += "\n<ul class=\"sublist_#{level}\">\n"
            level += 1
            html = build_nav_nodes page, grouped_pages, html, level, options
            level -= 1
            html += "</ul>\n"
          end
          html += "</li>\n"
        end
      end
      return html
    end

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
      css_classes << "selected" if mark_as_root_of_current? page

      unless css_classes.empty?
        return " class=\"#{css_classes.join(' ')}\""
      else
        return ""
      end
    end
end
