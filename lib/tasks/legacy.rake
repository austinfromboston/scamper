require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'
require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")
namespace :legacy do
  desc 'import legacy AMP data'
  task :import do
    LegacyImporter.run
  end
end


