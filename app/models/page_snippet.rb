class PageSnippet < ActiveRecord::Base
  # Validations
  validates :name, :presence => true, :uniqueness => true
  
  # Relationships
  if PageEngine.class_exists?('Asset')
    has_assets
  end

  def to_s
    if content
      case filter
        when "none"
          content.html_safe
        when "textile"
          RedCloth.new(content).to_html.html_safe
        when "markdown"
          BlueCloth.new(content).to_html.html_safe
        when "erb"
          require "erb"
          eval(ERB.new(content).src).html_safe
        when "erb+textile"
          require "erb"
          textilize eval(ERB.new(content).src).html_safe
        when "html"
          content.html_safe
      end      
    end
  end
end
