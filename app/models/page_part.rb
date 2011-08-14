class PagePart < ActiveRecord::Base
  # Relationships
  belongs_to :page

  # Validations
  validates :title, :uniqueness => {:scope => "page_id"}, :presence => true

  # Public methods

  def duplicate
    page_part = PagePart.new(self.attributes)
    page_part.save
    page_part
  end

  def to_s
    if content
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
end

