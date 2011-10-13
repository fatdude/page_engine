module PageEngine
  module Generators
    require 'rails/generators'
    require 'rails/generators/migration'

    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      desc "This generator installs PageEngine supporting assets"

      source_root File.expand_path('../../../../../', __FILE__) 
      
      def self.next_migration_number(path)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end
      
      def install
        if Rails.version < "3.1"
          create_migrations
          copy_stylesheets
          copy_javascripts
          copy_images
        end
        copy_file 'lib/generators/page_engine/templates/page_engine.rb', 'config/initializers/page_engine.rb'
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
          ['textile', 'markdown', 'html'].each do |area|
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
          directory 'vendor/assets/images', 'public/images'            
        end

    end
  end
end
