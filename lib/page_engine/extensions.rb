require 'page_engine/class_methods'
require 'page_engine/instance_methods'
require 'page_engine/exceptions'

class << ActionController::Base
  def page_engine(options = {})
#    # Check options
#    raise PageEngine::PageEngineException.new("Options for page_engine must be in a hash.") unless options.is_a? Hash
#    
#    options = {
#      :layouts = ['application']
#    }.merge(options)
    
#    options.each do |key, value|
#      unless [:layouts].include?(key)
#        raise PageEngine::PageEngineException.new("Unknown option for page_engine: #{key.inspect} => #{value.inspect}.")
#      end
#    end
  
    include PageEngine::InstanceMethods
    extend PageEngine::ClassMethods
    
    before_filter :find_page
    layout :get_layout
    
#    PageEngine.layouts = options[:layouts].is_a?(Array) ? options[:layouts] : ['application']
  end
end
