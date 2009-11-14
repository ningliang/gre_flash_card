require 'rubygems'
require 'sinatra' 

set :public, File.join(File.dirname(__FILE__), 'public')
set :views, File.join(File.dirname(__FILE__), 'views')
set :environment, :production

disable :run, :reload

require 'application'
run Sinatra::Application