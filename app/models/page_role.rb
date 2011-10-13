class PageRole < ActiveRecord::Base
  # Relationships
  belongs_to :required_role, :class_name => PageEngine.role_class
  belongs_to :excluded_role, :class_name => PageEngine.role_class
  
  # Scopes
  scope :viewable_by, lambda { |user| user ? where(:required_role_id => user.send("#{PageEngine.role_class.underscore}_ids")) : scoped }
  scope :not_viewable_by, lambda { |user| user ? where(['excluded_role_id not in (?)', user.send("#{PageEngine.role_class.underscore}_ids")]) : scoped }
  
  class << self
    
    def viewable_page_ids_for(user)
      PageRole.viewable_by(user).select(:page_id).map(&:page_id) - PageRole.not_viewable_by(user).select(:page_id).map(&:page_id)
    end
    
  end
end
