class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title
      t.text :meta_description
      t.text :meta_keywords
      t.text :status
      t.datetime :publish_from
      t.datetime :publish_to
      t.string :authorable_type
      t.id :authorable_id
      t.string :permalink
      t.string :url
      t.boolean :display_in_meny, :default => true
      t.boolean :display_in_sitemap, :default => true
      t.string :menu_css
      t.boolean :no_link, :default => false
      t.string :controller
      t.string :action
      t.string :layout
      t.text :js
      t.text :css
      t.string :ancestry

      t.timestamps
    end
    
    add_index :pages, :permalink
    add_index :pages, :url
    add_index :pages, [:controller, :action]
    add_index :pages, [:ancestry]
  end
end
