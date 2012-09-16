require 'sinatra'
require 'datamapper'
require 'pusher'
require 'rdiscount'
require './config/pusher_credentials' if File.exists?('./config/pusher_credentials.rb')
require 'active_support'
require 'time-ago-in-words'
require 'json'
require './config/database'
require 'useragent'

configure :production do
  require 'newrelic_rpm'
end

set :markdown, :layout_engine => :erb

# sessions: Support for encrypted, cookie-based sessions
# logging:  Writes a single line to STDERR in Apache common log format
enable :sessions, :logging

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
    user_agent = UserAgent.parse(request.env['HTTP_USER_AGENT'])
    
    @activity  = Activity.create(
      :fracture_id => @fracture.id,
      :host_ip => request.env['REMOTE_ADDR'],
      :browser => user_agent.browser,
      :version => user_agent.version.to_s.gsub(/[^0-9|.]/,'').split('.')[0].to_i,
      :platform => user_agent.platform,
      :is_mobile => user_agent.mobile?
    )
    
    redirect @fracture.url
  else
    erb :not_found, :layout => false
  end
end

post '/' do
  content_type :json
  
  @fracture = Fracture.new(
    :url => params[:url],
    :encoded_uri => '',
    :created_at => Time.now
  )
    
  if @fracture.save
    if @fracture.update(:encoded_uri => @fracture.id.to_s(36))
      { :fractured_url => "http://fracture.it/#{@fracture.encoded_uri}" }.to_json
    end
  else
    @fracture.errors.each do |e|
      Pusher['test_channel'].trigger('errors', { :message => e })
    end
    { :fractured_url => '', :error => @fracture.errors.full_messages }.to_json
  end
end

get '/documentation/analysis' do
  @activities = Activity.all
  erb :analysis, :layout => false
end

get '/documentation/api' do
  markdown :api, :layout => :markdown
end

get '/documentation/encoding' do
  markdown :encoding, :layout => :markdown
end
