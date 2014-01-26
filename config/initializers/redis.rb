#uri = URI.parse("redis://redistogo:961c21713a0f5f8aecaec0b7690bb217@char.redistogo.com:9075/")
#REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
#Resque.redis = REDIS

require 'resque'
require 'resque/server'

uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://localhost:6379/" )
Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

# Load all jobs at /app/jobs
Dir["#{Rails.root}/app/workers/*.rb"].each { |file| require file }
