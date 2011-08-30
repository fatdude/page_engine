require 'page_engine/class_methods'
require 'page_engine/instance_methods'
require 'page_engine/exceptions'

class << ActionController::Base
  def page_engine(options = {})
  
    include PageEngine::InstanceMethods
    extend PageEngine::ClassMethods
    
    before_filter :find_page
    layout :get_layout
  end
end
