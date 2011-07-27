# Metricsd

Metricsd is a pure Ruby client library for the [MetricsD](https://github.com/kpumuk/metricsd) server.

## Installation

Add the "metricsd" gem to your `Gemfile`.

    gem 'metricsd'

And run `bundle install` command.

## Getting started

You can configure Metricsd connection parameters by accessing attributes of `Metricsd` module:

    Metricsd.server_host = 'metrics.local'
    Metricsd.server_port = 6311

There are few more setting, please check project documentation.

Now you should be able to record you metrics:

    # Record success hit
    Metricsd::Client.record_success("api.docs.upload")
    # Record failure hit
    Metricsd::Client.record_failure("api.docs.upload")
    # Record timing info
    Metricsd::Client.record_time("api.docs.upload", 0.14)
    # Record complete success hit info (count + timing)
    Metricsd::Client.record_hit("api.docs.upload", true, 0.14)
    # Record an integer value
    Metricsd::Client.record_value("user.password.size", 15)
    Metricsd::Client.record_value("user.age", 26)

You can combine you metrics to send them in a single network packet for performance reason:

    # Send all database pool stats
    Metricsd::Client.record_values({
      'db.pool.reserved'  => db_stats[:reserved],
      'db.pool.available' => db_stats[:available],
      'db.pool.pending'   => db_stats[:pending],
    }, :group => 'doc_timestamp')

You can specify message source using :source => 'src' option. In this case you will be able to see summary graphs and graphs per source:

    # Generate graphs for all tables, and each single table.
    Metricsd::Client.record_success("hbase.reads", :source => @hbase_table)

By default only summary statistics is calculated. You can enable per-host graphs by specifying the appropriate source:

    # Generate summary graph for all hosts, and graphs for each single host.
    Metricsd::Client.record_success("hbase.reads", :source => Metricsd::Client.source)
    # ... or you can pass an empty string with the same effect.
    Metricsd::Client.record_success("hbase.reads", :source => '')

You can group your metrics using :group option. In this case metrics will be displayed together on the summary page.

    # Group metrics using :group option.
    Metricsd::Client.record_success("reads", :source => @hbase_table, :group => 'hbase')
    # Group metrics using special syntax "group$metric".
    Metricsd::Client.record_success("hbase$reads", :source => @hbase_table)

## More info

Check the [Project Documentation](http://rubydoc.info/gems/metricsd/) or check the tests to find out how to use this client.
