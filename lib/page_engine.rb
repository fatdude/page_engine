require 'page_engine/defaults'
require "page_engine/engine"
require 'page_engine/extensions'
require 'page_engine/helpers'
require 'page_engine/routes_finder'
require 'RedCloth'
require 'bluecloth'
require 'haml'
require 'simple_form'
require 'awesome_nested_set'

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

ActionView::Helpers::AssetTagHelper.register_javascript_expansion :page_engine => ["jquery-ui-1.8.15.custom.min", "jquery.ui.nestedSortable", "jquery.markitup", "markitup/sets/html/set", "markitup/sets/textile/set", "markitup/sets/markdown/set", "markitup/sets/css/set", "markitup/sets/javascript/set", "page_engine"]
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :page_engine => ["jquery-ui", "markitup/skins/simple/style", "markitup/sets/html/style", "markitup/sets/textile/style", "markitup/sets/markdown/style", "markitup/sets/css/style", "markitup/sets/javascript/style", "page_engine"]
