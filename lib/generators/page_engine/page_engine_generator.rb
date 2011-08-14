require 'rails/generators'
require 'rails/generators/migration'

class PageEngineGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  def self.source_root
    @source_root ||= File.join(File.dirname(__FILE__), 'templates')
  end

  # Implement the required interface for Rails::Generators::Migration.
  # taken from http://github.com/rails/rails/blob/master/activerecord/lib/generators/active_record.rb
  def self.next_migration_number(dirname)
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end

  def create_migrations
    begin
      migration_template 'create_cms.rb', 'db/migrate/create_cms.rb'
    rescue
      puts 'CMS migration already exists'
    end
    sleep 1
    begin
      migration_template 'create_page_roles.rb', 'db/migrate/create_page_roles.rb'
    rescue
      puts 'CMS migration already exists'
    end       
  end

end

