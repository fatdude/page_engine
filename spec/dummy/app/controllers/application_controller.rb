class ApplicationController < ActionController::Base
  protect_from_forgery
  
  page_engine(:layouts => ['application'])
end