require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'
require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")
namespace :legacy do
  desc 'import legacy AMP data'
  task :import do
    LegacyImporter.run
  end
  task :import_templates do
    PageLayout.delete_all if ENV["DROP"]
    imp = LegacyImporter.new
    imp.do_templates
  end
  task :import_navs do
    Page.delete_all [ "legacy_type like ?", '%nav_layout%' ] if ENV["DROP"]
    Article.delete_all [ "legacy_type = ?", 'nav' ] if ENV["DROP"]
    imp = LegacyImporter.new
    imp.do_navs
  end
end


