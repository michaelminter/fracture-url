require 'sinatra'
require 'pg'
require 'dm-core'
require 'dm-postgres-adapter'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-types'
require 'rack-flash'

enable :sessions
use Rack::Flash

helpers do
  # TODO: Put helpers here.
end

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/my.db")

# TODO: Add database models here.

DataMapper.finalize
DataMapper.auto_upgrade!

get '/' do
  erb :index
end

get '/*' do
  erb :not_found
end
