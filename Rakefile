require 'rubygems'
require 'sinatra'
require 'datamapper'

namespace :db do
  require './config/database'
  
  desc 'Load seed data'
  task :seed do
    DataMapper.repository(:default).adapter.execute("TRUNCATE fractures RESTART IDENTITY CASCADE;")
    puts "Removed all records from Fracture table"
  end
  
  desc 'Migrate database'
  task :migrate do
    DataMapper.auto_migrate!
    puts "Migrated Database"
  end
end