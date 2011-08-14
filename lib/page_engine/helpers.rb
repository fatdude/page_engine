module PageEngine
  %w{ pages_helper }.each do |h|
    require "#{PAGE_ENGINE_ROOT_PATH}/app/helpers/#{h}"
  end

  ActionView::Base.class_eval do
    include PagesHelper
  end
end

