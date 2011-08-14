class CreatePageEngine < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :title
      t.text :meta_description
      t.text :meta_keywords
      t.string :status
      t.datetime :publish_from
      t.datetime :publish_to
      t.integer :created_by
      t.string :permalink
      t.string :url
      t.boolean :display_in_menu, :default => true
      t.boolean :display_in_sitemap, :default => true
      t.string :menu_css_class
      t.boolean :no_link, :default => false
      t.string :controller
      t.string :action
      t.string :layout
      t.text :js
      t.text :css
      t.string :ancestry
      t.string :authorable_type
      t.integer :authorable_id

      t.timestamps
    end
      
    create_table :page_parts do |t|
      t.string :title
      t.text :content
      t.references :page
      t.string :filter

      t.timestamps
    end

    create_table :pages_roles, :id => false do |t|
      t.integer :page_id, :role_id
    end
    
    create_table :page_snippets do |t|
      t.string :name
      t.string :filter
      t.text :content

      t.timestamps
    end
    
    create_table :page_roles do |t|
      t.integer :page_id
      t.integer :required_role_id
      t.integer :excluded_role_id
    end
    
    add_index :pages, :permalink
    add_index :pages, [:controller, :action]
    add_index :pages, :url
    add_index :page_snippets, :name
  end

  def self.down
    remove_index :pages, :permalink
    remove_index :pages, [:controller, :action]
    remove_index :pages, :url
    remove_index :page_snippets, :name
    
    drop_table :pages
    drop_table :page_parts
    drop_table :pages_roles
    drop_table :page_snippets
    drop_table :page_roles
  end
end
