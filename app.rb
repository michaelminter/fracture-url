require 'sinatra'
require 'datamapper'
require './config/pusher_credentials' if File.exists?('./config/pusher_credentials.rb')
require 'active_support'
require 'time-ago-in-words'
require 'json'

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

DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/fracture")

class Fracture
  include DataMapper::Resource
  
  property :id, Serial
  property :url, String
  property :encoded_uri, String
  property :created_at, DateTime
  property :header_data, String
  
  before :save, :check_url
  after  :save, :encode_uri
  after  :save, :pusher_app
  
  def check_url
    self.url = ('http://' + self.url) unless self.url =~ /^https?:\/\//
  end
  
  def encode_uri
    self.update(:encoded_uri => self.id.to_s(36))
  end
  
  def pusher_app
    Pusher['test_channel'].trigger('my_event', { :id => self.id, :url => self.url, :encoded_uri => self.encoded_uri, :created_at => self.created_at.to_time.ago_in_words })
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!

get '/' do
  @fractures = Fracture.all(:limit => 5, :order => [ :created_at.desc ])
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
    { :fractured_url => "http://fracture.it/#{@fracture.encoded_uri}" }.to_json
  else
    { :fractured_url => "http://fracture.it/#{@fracture.encoded_uri}" }.to_json
  end
end
