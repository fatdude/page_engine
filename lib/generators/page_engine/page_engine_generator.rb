require 'rails/generators'
require 'rails/generators/migration'

class PageEngineGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  source_root File.expand_path('../../../../', __FILE__) 
  
  def self.next_migration_number(path)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end
  
  def install
    create_migrations
    copy_stylesheets
    copy_javascripts
    copy_images
    
    copy_file 'app/views/layouts/admin.html.haml', 'app/views/layouts/admin.html.haml'
  end

  private
  
    def create_migrations
      begin
        migration_template 'db/migrate/20110814185929_create_page_engine.rb', 'db/migrate/create_page_engine.rb'
      rescue Exception => e
        puts e
      end  
    end
    
    def copy_stylesheets
      directory 'app/assets/stylesheets', 'public/stylesheets'
      directory 'vendor/assets/stylesheets', 'public/stylesheets'
      
      puts 'Updating image location'
      ['css', 'textile', 'markdown', 'html', 'javascript'].each do |area|
        gsub_file "public/stylesheets/markitup/sets/#{area}/style.css", /\/assets\//, '/images/'
      end
      
      ['markitup', 'simple'].each do |area|
        gsub_file "public/stylesheets/markitup/skins/#{area}/style.css", /\/assets\//, '/images/'
      end
      
      gsub_file "public/stylesheets/jquery-ui.css", /\/assets\//, '/images/'
      gsub_file "public/stylesheets/page_engine.css", /\/assets\//, '/images/'
    end
    
    def copy_javascripts
      directory 'app/assets/javascripts', 'public/javascripts'
      directory 'vendor/assets/javascripts', 'public/javascripts'      
    end
    
    def copy_images
      directory 'app/assets/images', 'public/images'
      directory 'vendor/assets/images', 'public/images'            
    end

end

