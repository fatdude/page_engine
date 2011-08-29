PageEngine.setup do |config|
  # Layouts available to the psge
  config.layouts = [:application]
  
  # Page parts that are created by default with a new page
  config.page_parts = %w{ body left right header footer }
  
  # Extra page status options, added to defaults 
  config.statuses = [:under]
  
  # Filters that can be applied to the page parts content
  config.filters = %w{ html textile markdown }
end
