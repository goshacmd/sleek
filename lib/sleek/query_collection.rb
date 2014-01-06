module Sleek
  class QueryCollection
    class << self
      # Register a query.
      #
      # @param name [Symbol] query name
      # @param klass [Class] query class
      # @param options [Hash] options hash
      # @option options [Symbol] :alias alias name
      def register(name, klass, options = {})
        @registry ||= {}
        @aliases  ||= {}
        @registry[name] = klass

        alias_query(name, options[:alias]) if options[:alias]

        define_query_method(name)
      end

      # Define an alias for query name.
      #
      # @param query_name [Symbol] query name
      # @param alias_name [Symbol] alias name
      def alias_query(query_name, alias_name)
        @aliases ||= {}
        @aliases[alias_name] = query_name
        define_query_method(query_name, alias_name)
      end

      # Define a query method on collection.
      #
      # @param name [Symbol]
      # @param method_name [Symbol]
      def define_query_method(name, method_name = name)
        klass = @registry[name]

        define_method(method_name) do |bucket, options = {}|
          QueryCommand.new(klass, namespace, bucket, options).run
        end
      end
    end

    attr_reader :namespace

    # Initialize a new +QueryCollection+.
    #
    # @param namespace [Namespace]
    def initialize(namespace)
      @namespace = namespace
    end

    def inspect
      "#<Sleek::QueryCollection ns=#{namespace.name}>"
    end
  end
end
