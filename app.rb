require 'sinatra'
require 'datamapper'
require 'pusher'
require 'active_support'
require 'time-ago-in-words'

configure :development do
  Pusher.app_id = '27541'
  Pusher.key    = '28933f2d3f6fe14e0427'
  Pusher.secret = 'e59c16a50add5ed547b3'
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

# DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/fracture")
DataMapper.setup(:default, 'postgres://mgtdfbhwqwwluc:1Dw8jg-g0eZ3E_MLERlhpIlzf5@ec2-107-22-166-64.compute-1.amazonaws.com:5432/d7lnkaqmeb0c')

class Fracture
  include DataMapper::Resource
  
  property :id, Serial
  property :url, String
  property :encoded_uri, String
  property :created_at, DateTime
  property :header_data, String
end

DataMapper.finalize
DataMapper.auto_upgrade!

get '/' do
  logger.info "-----ENV-----#{ENV.inspect}"
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
  @fracture = Fracture.new(
    :url => params[:url],
    :encoded_uri => '',
    :created_at => Time.now,
    :header_data => params.to_json
  )
  if @fracture.save
    @fracture.encoded_uri = @fracture.id.to_s(36)
    if @fracture.save
      Pusher['test_channel'].trigger('my_event', { :id => @fracture.id, :url => @fracture.url, :encoded_uri => @fracture.encoded_uri, :created_at => @fracture.created_at.to_time.ago_in_words })
      "url: http://fracture.it/#{@fracture.encoded_uri}"
    end
  end
end
