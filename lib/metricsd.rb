require 'socket'
require 'logger'
require 'benchmark'

# Pure Ruby client library for MetricsD server.
module Metricsd
  class << self
    # Gets the MetricsD server host. Default is "127.0.0.1".
    def server_host
      @@server_host
    end

    # Sets the MetricsD server host.
    def server_host=(host)
      @@server_host = host
      Client.reset_connection!
    end

    # Gets the MetricsD server port. Default is 6311.
    def server_port
      @@server_port
    end

    # Sets the MetricsD server port.
    def server_port=(port)
      @@server_port = Integer(port)
      Client.reset_connection!
    end

    # Gets the source used to record host-specific metrics. Default is the
    # first part of the hostname (e.g. "test" for "test.host.com").
    def source
      @@source || metricsd.default_source
    end

    # Sets the source for host-specific metrics.
    def source=(source)
      @@source = source
    end

    # Gets the default source for all metrics. If nil or empty string — all
    # metrics will be host-specific (MetricsD server will generate per-host
    # graphs in addition to summary graph for all hosts for each metric).
    # Default is "all".
    def default_source
      @@default_source
    end

    # Sets the default source for all metrics.
    def default_source=(source)
      @@default_source = source
    end

    # Gets the logger used to output errors or warnings.
    def logger
      @@logger ||= if defined?(Rails)
        Rails.logger
      elsif defined?(Loops)
        Loops.logger
      else
        Logger.new(STDOUT)
      end
    end

    # Sets the logger used to output errors or warnings.
    def logger=(logger)
      @@logger = logger
    end

    # Resets all values to their default state (mostly for testing purpose).
    def reset_defaults!
      @@server_host    = '127.0.0.1'
      @@server_port    = 6311
      @@source         = Socket.gethostname[/^([^.]+)/, 1]
      @@default_source = 'all'
      @@logger         = nil
    end
  end

  reset_defaults!
end

require 'metricsd/client'
require "metricsd/version"
