class AddUsers < ActiveRecord::Migration
  def up
    create_table :weird_users do |t|
      t.string :name
    end
    
    create_table :odd_roles_weird_users, :id => false do |t|
      t.references :weird_user
      t.references :odd_role
    end
    
    weird_user = WeirdUser.create(:name => 'Bob')
    weird_user.odd_roles << OddRole.first
    weird_user.odd_roles << OddRole.last
  end

  def down
    drop_table :weird_users
    drop_table :odd_roles
  end
end
