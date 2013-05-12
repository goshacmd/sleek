![Sleek](sleek.png)

[![Build Status](https://travis-ci.org/goshakkk/sleek.png)](https://travis-ci.org/goshakkk/sleek)

Sleek is a gem for doing analytics. It allows you to easily collect and
analyze events that happen in your app.

**Sleek is a work-in-progress development. Use with caution.**

## Installation

The easiest way to install Sleek is to add it to your Gemfile:

```ruby
gem "sleek"
```

Or, if you want the latest hotness:

```ruby
gem "sleek", github: "goshakkk/sleek"
```

Then, install it:

```bash
$ bundle install
```

Sleek requires MongoDB to work and assumes that you have Mongoid
configured already.

Finally, create needed indexes:

```bash
$ rake db:mongoid:create_indexes
```

## Getting started

### Namespacing

Namespaces are a great way to organize entirely different buckets of
data inside a single application. In Sleek, everything is namespaced.

Creating a namespaced instance of Sleek is easy:

```ruby
sleek = Sleek[:my_namespace]
```

You then would just call everything on this instance.

### Sending an Event

The heart of analytics is in recording events. Events are things that
happen in your app that you want to track. Events are stored in event
buckets.

In order to send an event, you would simply need to call
`sleek.record`, passing the event bucket name and the event
payload.

```ruby
sleek.record(:purchases, {
  customer: { id: 1, name: "First Last", email: "first@last.com" },
  items: [{ sku: "TSTITM1", name: "Test Item 1", price: 1999 }],
  total: 1999
})
```

### Analyzing Events

#### Simple count

There are a few methods of analyzing your data. The simplest one is
counting. It, you guessed it, would count how many times the event has
occurred.

```ruby
sleek.queries.count(:purchases)
# => 42
```

#### Average

In order to calculate average value, it's needed to additionally specify
what property should the average be calculated based on:

```ruby
sleek.queries.average(:purchases, target_property: :total)
# => 1999
```

#### Query with timeframe

You can limit the scope of events that analysis is run on by adding the
`:timeframe` option to any query call.

```ruby
sleek.queries.count(:purchases, timeframe: :this_day)
# => 10
```

#### Query with interval

Some kinds of applications may need to analyze trends in the data. Using
intervals, you can break a timeframe into minutes, hours, days, weeks,
or months. One can do so by passing the `:interval` option to any query
call. Using `:interval` also requires that you specify `:timeframe`.

```ruby
sleek.queries.count(:purchases, timeframe: :this_2_days, interval: :daily)
# => [
#      {:timeframe=>2013-01-01 00:00:00 UTC..2013-01-02 00:00:00 UTC, :value=>10},
#      {:timeframe=>2013-01-02 00:00:00 UTC..2013-01-03 00:00:00 UTC, :value=>24}
#    ]
```

## Data analysis in more detail

### Metrics

The word "metrics" is used to describe analysis queries which return a
single numeric value.

### Count

Count just counts the number of events recorded.

```ruby
sleek.queries.count(:bucket)
# => 42
```

### Count unique

It counts how many events have an unique value for a given property.

```ruby
sleek.queries.count_unique(:bucket, params)
```

You must pass the target property name in params like this:

```ruby
sleek.queries.count_unique(:purchases, target_property: "customer.id")
# => 30
```

### Minimum

It finds the minimum numeric value for a given property. All non-numeric
values are ignored. If none of property values are numeric, nil will
be returned.

```ruby
sleek.queries.minimum(:bucket, params)
```

You must pass the target property name in params like this:

```ruby
sleek.queries.minimum(:purchases, target_property: "total")
# => 10_99
```

### Maximum

It finds the maximum numeric value for a given property. All non-numeric
values are ignored. If none of property values are numeric, nill will
be returned.

```ruby
sleek.queries.maximum(:bucket, params)
```

You must pass the target property name in params like this:

```ruby
sleek.queries.maximum(:purchases, target_property: "total")
# => 199_99
```

### Average

The average query finds the average value for a given property.  All
non-numeric values are ignored. If none of property values are numeric,
nil will be returned.

```ruby
sleek.queries.average(:bucket, params)
```

You must pass the target property name in params like this:

```ruby
sleek.queries.average(:purchases, target_property: "total")
# => 49_35
```

### Sum

The sum query sums all the numeric values for a given property. All
non-numeric values are ignored. If none of property values are numeric,
nil will be returned.

```ruby
sleek.queries.sum(:bucket, params)
```

You must pass the target property name in params like this:

```ruby
sleek.queries.sum(:purchases, target_property: "total")
# => 2_072_70
```

## Series

Series allow you to analyze trends in metrics over time. They break a
timeframe into intervals and compute the metric for those intervals.

Calculating series is simply done by adding the `:timeframe` and
`:interval` options to the metric query.

Valid intervals are:

* `:hourly`
* `:daily`
* `:weekly`
* `:monthly`

## Group by

In addition to using metrics and series, it is sometimes desired to
group their outputs by a specific property value.

For example, you might be wondering, "How much have me made from each of
our customers?" Group by will help you answer questions like this.

To group metrics or series result by value of some property, all you
need to do is to pass the `:group_by` option to the query.

```ruby
sleek.queries.sum(:purchases, target_property: "total", group_by: "customer.email")
# => {"first@another.com"=>214998, "first@last.com"=>64999}
```

Or, you may wonder how much did you make from each of your customers for
every day of this week.

```ruby
sleek.queries.sum(:purchases, target_property: "total", timeframe: :this_week,
  interval: :daily, group_by: "customer.email")
```

You can even combine it with filters. For example, how much did you make
from each of your customers for evey day of this weeks on orders greater
than $1000?

```ruby
sleek.queries.sum(:purchases, target_property: "total", filter: ["total", :gte, 1000_00],
  timeframe: :this_week, interval: :daily, group_by: "customer.email")
```

## Filters

To limit the scope of events used in analysis you can use a filter. To
do so, you just pass the `:filter` option to the query.

A single filter is a 3-element array, consisting of:

* `property_name` - the property name to filter.
* `operator` - the name of the operator to apply.
* `value` - the value used in operator to compare to property value.

Operators: eq, ne, lt, lte, gt, gte, in.

You can pass either a single filter or an array of filters.

```ruby
sleek.queries.count(:purchases, filters: [:total, :gt, 1599])
# => 20
```

## Other

### Deleting namespace

```ruby
sleek.delete!
```

### Deleting buckets

```ruby
sleek.delete_bucket(:purchases)
```

### Deleting property from all events in the bucket

```ruby
sleek.delete_property(:purchases, :some_property)
```

## License

[MIT](LICENSE).
