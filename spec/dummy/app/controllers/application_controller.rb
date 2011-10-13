class ApplicationController < ActionController::Base
  protect_from_forgery
  
  page_engine
  
  layout :get_layout
  
  def current_weird_user
    WeirdUser.first
  end
  helper_method :current_weird_user
  
  private 
  
    def get_layout
      if request.params[:controller] =~ /admin\//
        "admin/application"
      else
        "application"
      end
    end
end
