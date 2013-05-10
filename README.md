![Sleek](sleek.png)

Sleek is a gem for doing analytics. It allows you to easily collect and
analyze events that happen in your app.

## Installation

The easiest way to install Sleek is to add it to your Gemfile:

```ruby
gem "sleek"
```

Then, install it:

```
$ bundle install
```

Sleek requires MongoDB to work and assumes that you have Mongoid
configured already.

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
```

#### Average

In order to calculate average value, it's needed to additionally specify
what property should the average be calculated based on:

```ruby
sleek.queries.average(:purchases, target_property: :total) # => 1999
```

#### Query with timeframe

You can limit the scope of events that analysis is run on by adding the
`:timeframe` option to any query call.

```ruby
sleek.queries.count(:purchases, timeframe: :this_day)
```

#### Query with interval

Some kinds of applications may need to analyze trends in the data. Using
intervals, you can break a timeframe into minutes, hours, days, weeks,
or months. One can do so by passing the `:interval` option to any query
call. Using `:interval` also requires that you specify `:timeframe`.

```ruby
sleek.queries.count(:purchases, timeframe: :this_day, interval: :hourly)
```

## Data analysis in more detail

### Metrics

The word "metrics" is used to describe analysis queries which return a
single numeric value.

### Count

Count just counts the number of events recorded.

```ruby
sleek.queries.count(:bucket)
```

### Count unique

It counts how many events have an unique value for a given property.

```ruby
sleek.queries.count_unique(:bucket, params)
```

You must pass the target property name in params like this:

```ruby
sleek.queries.count_unique(:purchases, target_property: "customer.id")
```

### Minimum

It finds the minimum numeric value for a given property. All non-numeric
values are ignored. If none of property values are numeric, the
exception will be raised.

```ruby
sleek.queries.minimum(:bucket, params)
```

You must pass the target property name in params like this:

```ruby
sleek.queries.minimum(:purchases, target_property: "total")
```

### Maximum

It finds the maximum numeric value for a given property. All non-numeric
values are ignored. If none of property values are numeric, the
exception will be raised.

```ruby
sleek.queries.maximum(:bucket, params)
```

You must pass the target property name in params like this:

```ruby
sleek.queries.maximum(:purchases, target_property: "total")
```

### Average

The average query finds the average value for a given property.  All
non-numeric values are ignored. If none of property values are numeric,
the exception will be raised.

```ruby
sleek.queries.average(:bucket, params)
```

You must pass the target property name in params like this:

```ruby
sleek.queries.average(:purchases, target_property: "total")
```

### Sum

The sum query sums all the numeric values for a given property. All
non-numeric values are ignored. If none of property values are numeric,
the exception will be raised.

```ruby
sleek.queries.sum(:bucket, params)
```

You must pass the target property name in params like this:

```ruby
sleek.queries.sum(:purchases, target_property: "total")
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

## License

[MIT](LICENSE).
