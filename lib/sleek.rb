require 'mongoid'

require 'sleek/core_ext/range'
require 'sleek/core_ext/time'

require 'sleek/version'
require 'sleek/timeframe'
require 'sleek/interval'
require 'sleek/filter'
require 'sleek/group_by_criteria'
require 'sleek/event'
require 'sleek/query_command'
require 'sleek/query_collection'
require 'sleek/queries'
require 'sleek/namespace'

module Sleek
  class << self
    # Create a namespace with name +namespace+.
    #
    # @param namespace [String]
    #
    # @return [Namespace]
    def for_namespace(namespace)
      Namespace.new namespace
    end
    alias_method :[], :for_namespace
  end
end
