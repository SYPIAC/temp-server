require 'yaml'
require_relative 'db/seed'
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

namespace :db do
  task :setup do
    Rake::Task['db:create'].invoke
    Rake::Task['db:seed'].invoke
  end

  task :create do
    Dir.mkdir("db") unless Dir.exist?("db")
    File.open("./db/records.yml","a")
  end

  task :seed do
    f = File.open("./db/records.yml","a")
    seed.each do |x|
      f.write(YAML.dump(x))
    end
    f.close
  end

  task :drop do
    File.delete("./db/records.yml")
  end
end
