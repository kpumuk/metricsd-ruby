module Metricsd
  # Client class implements MetricsD protocol, allowing to send various metrics
  # to the MetricsD server for collecting, analyzing, and graphing them.
  #
  # Class allows to record count and timing stats to the database:
  #
  #   # Record success hit
  #   Metricsd::Client.record_success("api.docs.upload")
  #   # Record failure hit
  #   Metricsd::Client.record_failure("api.docs.upload")
  #   # Record timing info
  #   Metricsd::Client.record_time("api.docs.upload", 0.14)
  #   # Record complete success hit info (count + timing)
  #   Metricsd::Client.record_hit("api.docs.upload", true, 0.14)
  #   # Record an integer value
  #   Metricsd::Client.record_value("user.password.size", 15)
  #   Metricsd::Client.record_value("user.age", 26)
  #
  # To send several metrics in a single network packet, you can use record_values:
  #
  #   # Send all database pool stats
  #   Metricsd::Client.record_values({
  #     'db.pool.reserved'  => db_stats[:reserved],
  #     'db.pool.available' => db_stats[:available],
  #     'db.pool.pending'   => db_stats[:pending],
  #   }, :group => 'doc_timestamp')
  #
  # You can specify message source using <tt>:source => 'src'</tt> option. In this case
  # you will be able to see summary graphs and graphs per source:
  #
  #   # Generate graphs for all tables, and each single table.
  #   Metricsd::Client.record_success("hbase.reads", :source => @hbase_table)
  #
  # By default only summary statistics is calculated. You can enable per-host graphs
  # by specifying the appropriate source:
  #
  #   # Generate summary graph for all hosts, and graphs for each single host.
  #   Metricsd::Client.record_success("hbase.reads", :source => Metricsd::Client.source)
  #   # ... or you can pass an empty string with the same effect.
  #   Metricsd::Client.record_success("hbase.reads", :source => '')
  #
  # You can group your metrics using <tt>:group</tt> option. In this case metrics will be
  # displayed together on the summary page.
  #
  #   # Group metrics using :group option.
  #   Metricsd::Client.record_success("reads", :source => @hbase_table, :group => 'hbase')
  #   # Group metrics using special syntax "group$metric".
  #   Metricsd::Client.record_success("hbase$reads", :source => @hbase_table)
  #
  class Client
    class << self
      # Record complete hit info. Time should be a floating point
      # number of seconds.
      #
      # It creates two metrics:
      # * +your.metric.count+ with counts of failed and succeded events
      # * +your.metric.time+ with time statistics
      #
      # @param [String] metric is the metric name (like app.docs.upload)
      # @param [Boolean] is_success indicating whether request was successful.
      # @param [Float] time floating point number of seconds.
      # @param [Hash] opts options.
      # @option opts [String] :sep ("_") separator used to add suffixes +count+ and +time+.
      # @option opts [String] :group metrics group.
      # @option opts [String] :source metric source.
      #
      def record_hit(metric, is_success, time, opts = {})
        sep = opts[:sep] || opts[:separator] || '_'
        record_internal({
            "#{metric}#{sep}count" => is_success ? 1 : -1,
            "#{metric}#{sep}time"  => (time * 1000).round
          }, opts
        )
      end

      # Record succeded boolean event.
      #
      # It creates a single metric:
      # * +your.metric.count+ with numbers of failed and succeded events
      #
      # @param [String] metric is the metric name (like app.docs.upload)
      # @param [Hash] opts options.
      # @option opts [String] :sep ("_") separator used to add suffixes +count+ and +time+.
      # @option opts [String] :group metrics group.
      # @option opts [String] :source metric source.
      #
      def record_success(metric, opts = {})
        sep = opts[:sep] || opts[:separator] || '_'
        record_internal({"#{metric}#{sep}count" => 1}, opts)
      end

      # Record failed boolean event.
      #
      # It creates a single metric:
      # * +your.metric.count+ with numbers of failed and succeded events
      #
      # @param [String] metric is the metric name (like app.docs.upload)
      # @param [Hash] opts options.
      # @option opts [String] :sep ("_") separator used to add suffixes +count+ and +time+.
      # @option opts [String] :group metrics group.
      # @option opts [String] :source metric source.
      #
      def record_failure(metric, opts = {})
        sep = opts[:sep] || opts[:separator] || '_'
        record_internal({"#{metric}#{sep}count" => -1}, opts)
      end

      # Record timing info. Time should be a floating point
      # number of seconds.
      #
      # It creates a single metric:
      # * +your.metric.time+ with time statistics
      #
      # @param [String] metric is the metric name (like app.docs.upload)
      # @param [Float] time floating point number of seconds.
      # @param [Hash] opts options.
      # @option opts [String] :sep ("_") separator used to add suffixes +count+ and +time+.
      # @option opts [String] :group metrics group.
      # @option opts [String] :source metric source.
      #
      def record_time(metric, time = nil, opts = {}, &block)
        opts, time = time, nil if Hash === time
        sep = opts[:sep] || opts[:separator] || '_'
        if time.nil?
          raise ArgumentError, "You should pass a block if time is not given" unless block_given?
          time = Benchmark.measure(&block).real
        end
        record_internal({"#{metric}#{sep}time" => (time * 1000).round}, opts)
      end

      # Record an integer value.
      #
      # It creates a single metric:
      # * +your.metric+ with values statistics
      #
      # @param [String] metric is the metric name (like app.docs.upload)
      # @param [Integer] value metric value.
      # @param [Hash] opts options.
      # @option opts [String] :sep ("_") separator used to add suffixes +count+ and +time+.
      # @option opts [String] :group metrics group.
      # @option opts [String] :source metric source.
      #
      def record_value(metric, value, opts = {})
        record_internal({metric => value.round}, opts)
      end

      # Record multiple integer values.
      #
      # It creates a metric for each entry in +metrics+ Hash:
      # * +your.metric+ with values statistics
      #
      # @param [Hash] metrics a +Hash+ that maps metrics names to their values.
      # @param [Hash] opts options.
      # @option opts [String] :sep ("_") separator used to add suffixes +count+ and +time+.
      # @option opts [String] :group metrics group.
      # @option opts [String] :source metric source.
      #
      # @example
      #   Metricsd::Client.record_values(
      #     'db.pool.reserved'  => db_stats[:reserved],
      #     'db.pool.available' => db_stats[:available],
      #     'db.pool.pending'   => db_stats[:pending],
      #   )
      #
      def record_values(metrics, opts = {})
        record_internal(metrics, opts)
      end

      # Reset and re-establish connection.
      def reset_connection!
        @@socket = nil
      end

    private

      # Returns a UDP socket used to send metrics to MetricsD.
      def collector_socket
        @@socket ||= begin
          @@socket = UDPSocket.new
          @@socket.connect(Metricsd.server_host, Metricsd.server_port)
        end
      end

      # Send informating to the RRD collector daemon using UDP protocol.
      def record_internal(metrics, opts = {})
        return unless Metricsd.enabled?

        opts = { :source => Metricsd.default_source }.update(opts)
        opts[:source] = Metricsd.source if opts[:source].empty?

        # Build the message for
        send_in_packets Array(metrics).map { |arg| pack(arg[0], arg[1], opts) }.sort
      end

      # Combines string representations of metrics into packets of 250 bytes and
      # sends them to MetricsD.
      def send_in_packets(strings)
        msg = ''
        strings.each do |s|
          if s.size > 250
            Metricsd.logger.warn("Message is larger than 250 bytes, so it was ignored: #{s}")
            next
          end

          if msg.size + s.size + (msg.size > 0 ? 1 : 0) > 250
            safe_send(msg)
            msg = ''
          end
          msg << (msg.size > 0 ? ';' : '') << s
        end
        safe_send(msg) if msg.size > 0
      end

      # Sends a string to the MetricsD. Should never raise any network-specific
      # exceptions, but log them instead, and silently return.
      def safe_send(msg)
        collector_socket.send(msg, 0)
        true
      rescue Errno::ECONNREFUSED => e
        Metricsd.logger.error("Exception occurred while trying to send data to metricsd: #{e.inspect}")
        e.backtrace.each { |line| Metricsd.logger.error(line) }
        false
      end

      # Packs metric into a string representation according to the MetricsD
      # protocol.
      def pack(key, value, opts)
        key = "#{opts[:group]}$#{key}" unless opts[:group].nil? || opts[:group].empty?
        opts[:source].empty? ? "#{key}:#{value}" : "#{opts[:source]}@#{key}:#{value}"
      end
    end
  end
end
