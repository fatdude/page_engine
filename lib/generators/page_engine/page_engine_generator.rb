require 'rails/generators'
require 'rails/generators/migration'

class PageEngineGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  def self.source_root
    @source_root ||= File.join(File.dirname(__FILE__), '../../../../')
  end
  
  def self.next_migration_number(path)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end
  
  def install
    create_migrations
  end

  private
  
    def create_migrations
      begin
        migration_template 'db/migrate/20110814185929_create_page_engine.rb', 'db/migrate/create_page_engine.rb'
      rescue
        puts 'PageEngine migration already exists'
      end  
    end

end

