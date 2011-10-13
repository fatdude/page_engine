class OddRole < ActiveRecord::Base
  # Relationships
  has_and_belongs_to_many :weird_users
end

