require 'rubygems'
require 'sinatra'
require 'pg'
require 'dm-core'
require 'dm-postgres-adapter'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-types'
require 'bcrypt'
require 'rack-flash'

# Enable sessions and use Rack Flash
enable :sessions
use Rack::Flash

# Some helpers that help you
helpers do

  # Allows use of "h" to escape HTML
  include Rack::Utils
  alias_method :h, :escape_html

  # Check to see if a user is logged in
  def logged_in?
    if request.cookies['userid']
      true
    else
      false
    end
  end

  # Add this to the top of a route to make it accessible only to logged in users
  def authorize!
    redirect '/' unless logged_in?
  end

  # Get the logged in user's ID
  def get_userid
    request.cookies['userid']
  end

  # Set the logged in user's ID (logging them in)
  def set_userid(id)
    response.set_cookie('userid', id)
  end

end

# ==============
# Database Setup
# ==============

# Set up the database connection
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/my.db")

# A basic user database model
class User

  include DataMapper::Resource

  property :id,         Serial
  property :username,   String,     :required => true, :unique => true
  property :password,   BCryptHash, :required => true, :length => 255
  property :created_at, DateTime

end

# Finalize the database and create the database tables if needed
DataMapper.finalize
DataMapper.auto_upgrade!

# ======
# Routes
# ======

# Show an index page
get '/' do
  erb :index
end

# Show a login form or log the user out
get '/login/?' do
  unless logged_in?
    erb :login
  else
    flash[:notice] = 'You have been logged out.'
    response.delete_cookie('userid')
    redirect '/'
  end
end

# Log the user in
post '/login/?' do
  user = User.first(:username => params[:username])
  if user
    if user.password == params[:password]
      set_userid(user.id)
      flash[:notice] = 'You are now logged in.'
      redirect '/'
    else
      flash[:notice] = 'Incorrect password.'
      redirect '/login'
    end
  else
    flash[:notice] = 'Incorrect username.'
    redirect '/login'
  end
end

# Catch any URL that wasn't already handled and show a 404 page
get '/*' do
  erb :notfound
end
