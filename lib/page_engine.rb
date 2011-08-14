require 'page_engine/defaults'
require "page_engine/engine"
require 'page_engine/extensions'
require 'page_engine/helpers'
require 'page_engine/routes_finder'
require 'haml'
require 'RedCloth'

module PageEngine
  def self.class_exists?(class_name)
    klass = Module.const_get(class_name)
    return klass.is_a?(Class)
    rescue NameError
      return false
  end
  
  def self.available_routes
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
