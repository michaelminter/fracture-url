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
  
  belongs_to :fracture
  
  validates_length_of :platform, :min => 1
  validates_uniqueness_of :host_ip, :scope => :fracture_id
end