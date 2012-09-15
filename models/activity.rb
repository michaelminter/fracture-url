class Activity
  include DataMapper::Resource
  
  property :id, Serial
  property :fracture_id, Integer
  property :host_ip, String
  property :browser, String
  property :version, Integer
  property :platform, String
  property :is_mobile, Boolean
  property :created_at, DateTime
end