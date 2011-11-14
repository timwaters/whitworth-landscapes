require 'rubygems'
require 'vendor/sinatra-1.3.1/lib/sinatra.rb'
require 'vendor/rack-1.3.5/lib/rack.rb'

path = "/path/to/app"
Sinatra::Base.set(:root, path)
set :root, path
set :run, false
set :app_file, 'app.rb'
set :environment, :development

require 'app.rb'
run Sinatra::Application
