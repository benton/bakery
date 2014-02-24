require 'bundler'
Bundler.setup
require 'yaml'
require 'json'
require 'dice_bag/tasks'
require "#{File.dirname(__FILE__)}/lib/bakery"

# load Rake tasks from lib/tasks
Dir["#{File.dirname(__FILE__)}/lib/tasks/*.rake"].sort.each {|ext| load ext}
