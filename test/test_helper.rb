require 'test/unit'
require 'fakefs/safe'
require 'cachet'

Cachet.setup do |config|
  config.logger =  Logger.new(STDOUT)
end