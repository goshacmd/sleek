require 'mongoid'

require 'sleek/core_ext/range'
require 'sleek/core_ext/time'

require 'sleek/version'
require 'sleek/timeframe'
require 'sleek/event'
require 'sleek/queries'
require 'sleek/query_collection'
require 'sleek/base'

module Sleek
  def self.for_namespace(namespace)
    Base.new namespace
  end
end
