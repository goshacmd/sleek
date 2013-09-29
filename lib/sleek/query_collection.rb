module Sleek
  class QueryCollection
    class << self
      # Public: Register a query.
      #
      # name  - the Symbol query name.
      # klass - the query class.
      def register(name, klass)
        @registry ||= {}
        @registry[name] = klass
        define_query_method(name)
      end

      # Internal: Define a query method on collection.
      def define_query_method(name)
        klass = @registry[name]

        define_method(name) do |bucket, options = {}|
          QueryCommand.new(klass, namespace, bucket, options).run
        end
      end
    end

    attr_reader :namespace

    # Inernal: Initialize query collection.
    #
    # namespace - the Sleek::Namespace object.
    def initialize(namespace)
      @namespace = namespace
    end

    def inspect
      "#<Sleek::QueryCollection ns=#{namespace.name}>"
    end
  end
end
