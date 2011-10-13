PageEngine.setup do |config|
  # Layouts available to the psge
  # config.layouts = [:application]
  
  # Page parts that are created by default with a new page
  # config.page_parts = %w{ body left right header footer }
  
  # Extra page status options, added to defaults 
  # config.statuses = []
  
  # Filters that can be applied to the page parts content
  # config.filters = %w{ none html textile markdown }
  
  # List of actions that should be included when getting the available routes
  # config.required_route_actions = %w{ index show new edit create update }
  
  # List of controllers that should be excluded when getting the available routes
  # config.excluded_route_controllers = []
  
  # To give more control over which controllers are returned
  # config.excluded_route_controllers_regex = /^admin.*/  
  
  # If a page should only be vieawable by a specific role set the role class here
  # config.role_class = 'Role'
  
  # Author class for the created pages
  # config.author_class = 'User'
  
  # Set the helper method that will be used to get the current author
  # config.current_author_helper = 'current_user'
  
  # Set the helper method that will be used to get the current viewer
  # config.current_viewer_helper = 'current_user'
end
