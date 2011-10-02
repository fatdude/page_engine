class AddOddRoles < ActiveRecord::Migration
  def up
    create_table :odd_roles do |t|
      t.string :name 
    end
    
    # Create some random roles for the dummy application
    ['Admin', 'Editor', 'Author', 'User'].each do |name|
      OddRole.create(:name => name)
    end
  end

  def down
    drop_table :odd_roles
  end
end
