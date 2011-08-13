class Page < ActiveRecord::Base
  # Relationships
  belongs_to :authorable, :polymorphic => true
end
