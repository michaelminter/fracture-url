require 'sinatra'
require 'datamapper'
require 'pusher'
require './config/pusher_credentials' if File.exists?('./config/pusher_credentials.rb')
require 'active_support'
require 'time-ago-in-words'
require 'json'
require './config/database'

configure :production do
  require 'newrelic_rpm'
end

enable :sessions

helpers do
  def cycle
    %w{even odd}[@_cycle = ((@_cycle || -1) + 1) % 2]
  end

  CYCLE = %w{even odd}
  def cycle_fully_sick
    CYCLE[@_cycle = ((@_cycle || -1) + 1) % 2]
  end
end

get '/' do
  @fractures = Fracture.all(:limit => 5, :order => [ :created_at.desc ])
  
  @pusher_api_key = Pusher.key
  
  erb :index
end

get '/:encoded_uri' do
  @fracture = Fracture.first(:encoded_uri => params[:encoded_uri])
  unless @fracture.nil?
    redirect @fracture.url
  else
    erb :not_found
  end
end

post '/' do
  content_type :json
  
  @fracture = Fracture.new(
    :url => params[:url],
    :encoded_uri => '',
    :created_at => Time.now,
    :header_data => params.to_json
  )
    
  if @fracture.save
    if @fracture.update(:encoded_uri => @fracture.id.to_s(36))
      { :fractured_url => "http://fracture.it/#{@fracture.encoded_uri}" }.to_json
    end
  end
end
