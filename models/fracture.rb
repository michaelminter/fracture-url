class Fracture
  include DataMapper::Resource
  
  property :id, Serial
  property :url, String, :length => 200, :required => true, :format => /\./
  property :encoded_uri, String
  property :created_at, DateTime
  
  has n, :activities
  
  # validates_format_of :url, :with => /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/, :message => 'Not a valid URL format'
  
  before :save, :check_url
  # after  :save, :encode_uri
  after  :update, :pusher_app
  
  def check_url
    self.url = ('http://' + self.url) unless self.url =~ /^https?:\/\//
  end
  
  # def encode_uri
    # self.update(:encoded_uri => self.id.to_s(36))
  # end
  
  def pusher_app
    Pusher['test_channel'].trigger('my_event', { :id => self.id, :url => self.url.length > 40 ? "#{self.url[0..40]}..." : self.url, :encoded_uri => self.encoded_uri, :created_at => self.created_at.to_time.ago_in_words })
  end
end