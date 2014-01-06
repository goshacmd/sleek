module Sleek
  # Criteria object for group_by queries.
  # The reason it exists is that it's not possible to group_by result of
  # normal MongoDB queries, so MongoDB's Aggregation Framework has to be
  # used.
  #
  # It provides common aggregates methods that normal criteria objects
  # have: +count+, +distinct+, +sum+, +avg+, +min+, and +max+, but
  # instead of just numbers, they return a hash of group value => number.
  class GroupByCriteria
    attr_reader :criteria, :group_by

    # Initialize a new +group_by+ criteria.
    #
    # @param criteria [Mongoid::Criteria] criteria to match events
    # @param group_by [String] name of the property to group by
    def initialize(criteria, group_by)
      @criteria = criteria
      @group_by = group_by
    end

    # Compute all possible aggregates.
    #
    # @param field [String, Symbol, nil] the name of the filed being
    # aggregated. If none is passed, aggregates will only count events
    # inside each group. If it is passed, min, max, sum, and avg will be also included.
    #
    # @param count_unique [Boolean] the boolean flag indicating whethere or not
    # counting distinct field values is needed. Off by default, because
    # calculation of distinct values adds two additional pipeline operators and
    # pushes every value to the set, which might make computation slower on
    # large datasets when you do NOT need to count unique values.
    #
    # @example
    #   gc.aggregates
    #   # => [
    #   #      {"_id"=>"customer1", "count"=>2},
    #   #      {"_id"=>"customer2", "count" => 1}
    #   #    ]
    #
    # @return [Array<Hash>] an array of groups. Each group is a hash with key "_id"
    # being the value of group_by property.
    def aggregates(field = nil, count_unique = false)
      pipeline = aggregates_pipeline(field, count_unique)
      criteria.collection.aggregate(pipeline).to_a
    end

    # Run the aggregation on field and only select group value
    # and some property.
    #
    # @param field [String, Symbol, nil] tha name of the field being aggregated
    # @param prop [String]
    # @param count_unique [Boolean]
    #
    # @see #aggregates
    #
    # @example
    #   gc.aggregates_prop(nil, "count")
    #   # => { unique_value_1: 42, unique_value_2: 12 }
    def aggregates_prop(field, prop, count_unique = false)
      aggregates = aggregates(field, count_unique)
      Hash[aggregates.map { |doc| [doc['_id'], doc[prop]] }]
    end

    def count
      aggregates_prop(nil, 'count')
    end

    def count_unique(field)
      aggregates_prop(field, 'count_unique', true)
    end

    def distinct(field)
      OpenStruct.new(count: count_unique(field))
    end

    def avg(field)
      aggregates_prop(field, 'avg')
    end

    def max(field)
      aggregates_prop(field, 'max')
    end

    def min(field)
      aggregates_prop(field, 'min')
    end

    def sum(field)
      aggregates_prop(field, 'sum')
    end

    # Create aggregation pipeline.
    #
    # @param field [String, Symbol, nil] the name of the field to aggregate
    # @param count_unique [Boolean] the flag indicating whethere or not to
    #                count unique values of the field or not. Off by
    #                default.
    #
    # @see #aggregates
    def aggregates_pipeline(field = nil, count_unique = false)
      db_group = "$#{group_by}"
      db_field = "$#{field}" if field

      pipeline = []

      crit = criteria

      crit = crit.ne(field => nil) if field
      pipeline << { "$match" => crit.ne(group_by => nil).selector }

      group_args = { "_id" => db_group, "count" => { "$sum" => 1 } }

      if field
        group_args.merge!({
          "max" => { "$max" => db_field },
          "min" => { "$min" => db_field },
          "sum" => { "$sum" => db_field },
          "avg" => { "$avg" => db_field }
        })

        if count_unique
          group_args.merge!({ "unique_set" => { "$addToSet" => db_field } })
        end
      end

      pipeline << { "$group" => group_args }

      if count_unique
        pipeline << { "$unwind" => "$unique_set" }
        pipeline << {
          "$group" => {
            "_id" => "$_id",
            "count_unique" => { "$sum" => 1 },
            "count" => { "$first" => "count" },
            "max" => { "$first" => "max" },
            "min" => { "$first" => "min" },
            "avg" => { "$first" => "avg" }
          }
        }
      end

      pipeline
    end
  end
end
