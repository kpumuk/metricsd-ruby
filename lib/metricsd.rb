require 'socket'
require 'logger'
require 'benchmark'

module Metricsd
  class << self
    def server_host
      @@server_host
    end

    def server_host=(host)
      @@server_host = host
      Client.reset_connection!
    end

    def server_port
      @@server_port
    end

    def server_port=(port)
      @@server_port = Integer(port)
      Client.reset_connection!
    end

    def source
      @@source || metricsd.default_source
    end

    def source=(source)
      @@source = source
    end

    def default_source
      @@default_source
    end

    def default_source=(source)
      @@default_source = source
    end

    def logger
      @@logger ||= if defined?(Rails)
        Rails.logger
      elsif defined?(Loops)
        Loops.logger
      else
        Logger.new(STDOUT)
      end
    end

    def logger=(logger)
      @@logger = logger
    end

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
