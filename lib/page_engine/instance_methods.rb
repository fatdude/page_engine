module PageEngine
  module InstanceMethods
    def get_layout
      if @page 
        @page.layout.blank? ? Page.default_layout.to_s : @page.layout.to_s
      else
        Page.default_layout.to_s
      end      
    end
    
    def find_page(permalink=nil)      
      if Page.should_be_found?(params)
        if permalink
          @page = Page.includes(:page_parts).published.viewable_by(get_current_page_viewer).where(:permalink => permalink)
        else
          @page = Page.includes(:page_parts).published.viewable_by(get_current_page_viewer).with_url(request, params).first
        end
        # See http://stackoverflow.com/questions/1595424/request-format-returning
        # This last format appears when the page is refreshed in IE
        get_breadcrumbs if request.format.html? || request.format == '*/*'
      end
    end

    def page_title_replace(models=[])
      models.each do |m|
        key = m.class.to_s.underscore
        @page.title.scan(/\{\{#{key}_([_a-z]*)\}\}/).uniq.flatten.each do |attribute|
          if m.whitelist.include?(attribute) && m.respond_to?(attribute)
            @page.title.gsub!("{{#{key}_#{attribute}}}", m[attribute])
            value = m.send(attribute)

            if value.is_a?(Date) || value.is_a?(Time)
              value = value.to_formatted_s(:short_ordinal)
            end

            @page.title.gsub!("{{#{key}_#{attribute}}}", value.to_s)
          else
            @page.title.gsub!("{{#{key}_#{attribute}}}", "<span style=\"color: red;\">###NOT SUPPORTED, try #{m.whitelist.to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or')}###")
          end
        end
      end
    end

    def breadcrumb_replace(models=[])
      models.each do |m|
        key = m.class.to_s.underscore
        @breadcrumbs.each do |breadcrumb|
          if breadcrumb.is_a? Page
            breadcrumb.title.scan(/\{\{#{key}_([_a-z]*)\}\}/).uniq.flatten.each do |attribute|
              if m.whitelist.include?(attribute) && m.respond_to?(attribute)
                breadcrumb.title.gsub!("{{#{key}_#{attribute}}}", m[attribute])
                value = m.send(attribute)

                if value.is_a?(Date) || value.is_a?(Time)
                  value = value.to_formatted_s(:short_ordinal)
                end

                breadcrumb.title.gsub!("{{#{key}_#{attribute}}}", value.to_s)
              else
                breadcrumb.title.gsub!("{{#{key}_#{attribute}}}", "<span style=\"color: red;\">###NOT SUPPORTED, try one of #{m.whitelist.join(',')}###")
              end
            end
          end
        end
      end
    end
      
    private

      def get_breadcrumbs
        if @page
          @breadcrumbs = @page.ancestors.for_nav.published.viewable_by(get_current_page_viewer).all
        else
          @breadcrumbs = []
        end
      end
      
      def get_current_page_viewer
        if PageEngine.has_viewers?
          user = send(PageEngine.current_viewer_helper)
        else
          user = nil
        end
      end
  end
end
