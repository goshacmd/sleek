require 'mongoid'

require 'sleek/core_ext/range'
require 'sleek/core_ext/time'

require 'sleek/version'
require 'sleek/timeframe'
require 'sleek/interval'
require 'sleek/filter'
require 'sleek/group_by_criteria'
require 'sleek/event'
require 'sleek/queries'
require 'sleek/query_collection'
require 'sleek/namespace'

module Sleek
  def self.for_namespace(namespace)
    Namespace.new namespace
  end

  def self.[](namespace)
    for_namespace(namespace)
  end
end
