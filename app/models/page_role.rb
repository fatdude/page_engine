class PageRole < ActiveRecord::Base
  # Relationships
  belongs_to :required_role, :class_name => 'Role'
  belongs_to :excluded_role, :class_name => 'Role'
  
  # Scopes
  scope :viewable_by, lambda { |user| where(:required_role_id => user.role_ids) } 
  scope :not_viewable_by, lambda { |user| where(:excluded_role_id => user.role_ids) }
  
  class << self
    def viewable_page_ids_for(user)
      PageRole.viewable_by(user).map(&:page_id) - PageRole.not_viewable_by(user).map(&:page_id)
    end
  end
end