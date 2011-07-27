require 'bundler/setup'
require 'metricsd'

describe Metricsd::Client do
  before :each do
    @socket = mock('Socket')
    Metricsd::Client.stub!(:collector_socket => @socket)
    Metricsd.stub!(:source => 'test')
  end

  describe 'connection' do
    it 'should not throw, but log exceptions on failure' do
      @socket.should_receive(:send).and_raise(Errno::ECONNREFUSED.new('exception from test'))
      Metricsd.logger.should_receive(:error).once.with(match(/exception from test/))
      Metricsd.logger.should_receive(:error).at_least(1) # stacktrace
      Metricsd::Client.record_value('custom.metric', 5)
    end
  end

  describe '.record_hit' do
    it 'should send two metrics in a single packet' do
      @socket.should_receive(:send).with('all@custom.metric_count:1;all@custom.metric_time:450', 0)
      Metricsd::Client.record_hit('custom.metric', true, 0.45)
    end

    it 'should handle is_success=false' do
      @socket.should_receive(:send).with('all@custom.metric_count:-1;all@custom.metric_time:450', 0)
      Metricsd::Client.record_hit('custom.metric', false, 0.45)
    end

    it 'should change separator if :sep option is specified' do
      @socket.should_receive(:send).with('all@custom.metric!count:1;all@custom.metric!time:450', 0)
      Metricsd::Client.record_hit('custom.metric', true, 0.45, :sep => '!')
    end

    it 'should apply group to both the metrics' do
      @socket.should_receive(:send).with('all@test$custom.metric_count:1;all@test$custom.metric_time:450', 0)
      Metricsd::Client.record_hit('custom.metric', true, 0.45, :group => 'test')
    end

    it 'should apply source if empty string passed' do
      @socket.should_receive(:send).with('test@custom.metric_count:1;test@custom.metric_time:450', 0)
      Metricsd::Client.record_hit('custom.metric', true, 0.45, :source => '')
    end

    it 'should apply source if specified' do
      @socket.should_receive(:send).with('test2@custom.metric_count:1;test2@custom.metric_time:450', 0)
      Metricsd::Client.record_hit('custom.metric', true, 0.45, :source => 'test2')
    end
  end

  describe '.record_success' do
    it 'should record successes' do
      @socket.should_receive(:send).with('all@custom.metric_count:1', 0)
      Metricsd::Client.record_success('custom.metric')
    end

    it 'should change separator if :sep option is specified' do
      @socket.should_receive(:send).with('all@custom.metric!count:1', 0)
      Metricsd::Client.record_success('custom.metric', :sep => '!')
    end

    it 'should apply group if specified' do
      @socket.should_receive(:send).with('all@test$custom.metric_count:1', 0)
      Metricsd::Client.record_success('custom.metric', :group => 'test')
    end

    it 'should apply source if empty string passed' do
      @socket.should_receive(:send).with('test@custom.metric_count:1', 0)
      Metricsd::Client.record_success('custom.metric', :source => '')
    end

    it 'should apply source specified' do
      @socket.should_receive(:send).with('test2@custom.metric_count:1', 0)
      Metricsd::Client.record_success('custom.metric', :source => 'test2')
    end
  end

  describe '.record_failure' do
    it 'should record failures' do
      @socket.should_receive(:send).with('all@custom.metric_count:-1', 0)
      Metricsd::Client.record_failure('custom.metric')
    end

    it 'should change separator if :sep option is specified' do
      @socket.should_receive(:send).with('all@custom.metric!count:-1', 0)
      Metricsd::Client.record_failure('custom.metric', :sep => '!')
    end

    it 'should apply group if specified' do
      @socket.should_receive(:send).with('all@test$custom.metric_count:-1', 0)
      Metricsd::Client.record_failure('custom.metric', :group => 'test')
    end

    it 'should apply source if empty string passed' do
      @socket.should_receive(:send).with('test@custom.metric_count:-1', 0)
      Metricsd::Client.record_failure('custom.metric', :source => '')
    end

    it 'should apply source specified' do
      @socket.should_receive(:send).with('test2@custom.metric_count:-1', 0)
      Metricsd::Client.record_failure('custom.metric', :source => 'test2')
    end
  end

  describe '.record_time' do
    it 'should record time if specified' do
      @socket.should_receive(:send).with('all@custom.metric_time:450', 0)
      Metricsd::Client.record_time('custom.metric', 0.45)
    end

    it 'should yield a block if time is not specified' do
      @socket.should_receive(:send).with(match(/all@custom.metric_time:1\d{2}/), 0)
      yielded = false
      Metricsd::Client.record_time('custom.metric') do
        yielded = true
        sleep 0.1
      end
      yielded.should be_true
    end

    it 'should use options if time is not specified' do
      @socket.should_receive(:send).with(match(/all@custom.metric_time:\d+/), 0)
      yielded = false
      Metricsd::Client.record_time('custom.metric', {}) do
        yielded = true
      end
      yielded.should be_true
    end

    it 'should change separator if :sep option is specified' do
      @socket.should_receive(:send).with('all@custom.metric!time:450', 0)
      Metricsd::Client.record_time('custom.metric', 0.45, :sep => '!')
    end

    it 'should apply group if specified' do
      @socket.should_receive(:send).with('all@test$custom.metric_time:450', 0)
      Metricsd::Client.record_time('custom.metric', 0.45, :group => 'test')
    end

    it 'should apply source if empty string passed' do
      @socket.should_receive(:send).with('test@custom.metric_time:450', 0)
      Metricsd::Client.record_time('custom.metric', 0.45, :source => '')
    end

    it 'should apply source specified' do
      @socket.should_receive(:send).with('test2@custom.metric_time:450', 0)
      Metricsd::Client.record_time('custom.metric', 0.45, :source => 'test2')
    end
  end

  describe '.record_value' do
    it 'should record value' do
      @socket.should_receive(:send).with('all@custom.metric:23', 0)
      Metricsd::Client.record_value('custom.metric', 23)
    end

    it 'should apply group if specified' do
      @socket.should_receive(:send).with('all@test$custom.metric:23', 0)
      Metricsd::Client.record_value('custom.metric', 23, :group => 'test')
    end

    it 'should apply source if empty string passed' do
      @socket.should_receive(:send).with('test@custom.metric:23', 0)
      Metricsd::Client.record_value('custom.metric', 23, :source => '')
    end

    it 'should apply source specified' do
      @socket.should_receive(:send).with('test2@custom.metric:23', 0)
      Metricsd::Client.record_value('custom.metric', 23, :source => 'test2')
    end
  end

  describe '.record_values' do
    it 'should record all the values specified' do
      @socket.should_receive(:send).with('all@another.metric:47;all@custom.metric:23', 0)
      Metricsd::Client.record_values({'custom.metric' => 23, 'another.metric' => 47})
    end

    it 'should apply group if specified' do
      @socket.should_receive(:send).with('all@test$another.metric:47;all@test$custom.metric:23', 0)
      Metricsd::Client.record_values({'custom.metric' => 23, 'another.metric' => 47}, :group => 'test')
    end

    it 'should apply source if empty string passed' do
      @socket.should_receive(:send).with('test@another.metric:47;test@custom.metric:23', 0)
      Metricsd::Client.record_values({'custom.metric' => 23, 'another.metric' => 47}, :source => '')
    end

    it 'should apply source specified' do
      @socket.should_receive(:send).with('test2@another.metric:47;test2@custom.metric:23', 0)
      Metricsd::Client.record_values({'custom.metric' => 23, 'another.metric' => 47}, :source => 'test2')
    end

    it 'should split packets in 250 bytes' do
      packets, metrics = Array.new(2) { '' }, {}
      1.upto(8) do |metric|
        packet, name, value = (metric - 1) / 4, "my.super.long.custom.metric#{metric}", 10000000 + metric
        metrics[name] = value
        packets[packet] << "my.super.long.host.name@#{name}:#{value}" << (metric % 4 > 0 ? ';' : '')
      end

      @socket.should_receive(:send).once.with(packets[0], 0)
      @socket.should_receive(:send).once.with(packets[1], 0)
      Metricsd::Client.record_values(metrics, :source => 'my.super.long.host.name')
    end

    it 'should not allow packets larger than 250 bytes' do
      @socket.should_not_receive(:send)
      Metricsd.logger.should_receive(:warn).with(match(/Message is larger than 250 bytes/))
      Metricsd::Client.record_values({'a' * 300 => 5}, :source => 'my.super.long.host.name')
    end
  end
end
