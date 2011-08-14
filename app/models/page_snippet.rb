class PageSnippet < ActiveRecord::Base
  # Validations
  validates :name, :presence => true, :uniqueness => true
  
  # Relationships
  has_assets

  def to_s
    case filter
      when "none"
        content.html_safe
      when "textile"
        textilize(content).html_safe
      when "erb"
        require "erb"
        eval(ERB.new(content).src).html_safe
      when "erb+textile"
        require "erb"
        textilize eval(ERB.new(content).src).html_safe
      when "wysiwyg"
        content.html_safe
    end
  end
end
