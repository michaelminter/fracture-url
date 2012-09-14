require 'rubygems'
require 'datamapper'
require './models/Fracture'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/fracture")

DataMapper.finalize
DataMapper.auto_upgrade!
