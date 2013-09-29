module Sleek
  class QueryCollection
    class << self
      # Public: Register a query.
      #
      # name    - the Symbol query name.
      # klass   - the query class.
      # options - the options hash:
      #           :alias - the Symbol alias name.
      def register(name, klass, options = {})
        @registry ||= {}
        @aliases  ||= {}
        @registry[name] = klass

        alias_query(name, options[:alias]) if options[:alias]

        define_query_method(name)
      end

      # Public: Define an alias for query name.
      #
      # query_name - the Symbol query name.
      # alias_name - the Symbol alias name.
      def alias_query(query_name, alias_name)
        @aliases ||= {}
        @aliases[alias_name] = query_name
        define_query_method(query_name, alias_name)
      end

      # Internal: Define a query method on collection.
      def define_query_method(name, method_name = name)
        klass = @registry[name]

        define_method(method_name) do |bucket, options = {}|
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
