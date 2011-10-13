class WeirdUser < ActiveRecord::Base
  # Relationships
  has_and_belongs_to_many :odd_roles
  
  def to_s
    self.name
  end
end
