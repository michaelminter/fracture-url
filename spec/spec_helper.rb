require File.join(File.dirname(__FILE__), '..', 'app.rb')

require 'spec'
require 'rack/test'

set :environment, :test

Spec::Runner.configure do |conf|
  conf.include Rack::Test::Methods
end
