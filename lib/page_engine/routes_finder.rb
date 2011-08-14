module PageEngine
  class RoutesFinder
    def self.available
      available = {}

      Rails.application.routes.routes.each do |route|
        unless route.requirements.empty?
          unless ['DELETE'].include?(route.verb.to_s) || route.requirements[:controller].match(/^admin.*/) || ['delete', :delete].include?(route.requirements[:method].to_s)
            available[route.requirements[:controller]] = [] unless available[route.requirements[:controller]]
            unless route.requirements[:controller] == 'pages' && route.requirements[:action] == 'show'
              available[route.requirements[:controller]] << route.requirements[:action] unless available[route.requirements[:controller]].include?(route.requirements[:action])
            end
          end

        end
      end

      available.delete('rails/info')
      available
    end
  end
end

