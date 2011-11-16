require 'bundler/setup'
require 'metricsd'

describe Metricsd::Client do
  before :each do
    @socket = mock('Socket')
    Metricsd::Client.stub!(:collector_socket => @socket)
    # Global settings
    Metricsd.reset_defaults!
    Metricsd.source = 'test'
  end

  describe 'connection' do
    it 'should not throw, but log exceptions on failure' do
      @socket.should_receive(:send).and_raise(Errno::ECONNREFUSED.new('exception from test'))
      Metricsd.logger.should_receive(:error).once.with(match(/exception from test/))
      Metricsd::Client.record_value('custom.metric', 5)
    end

    it 'should not send anything to the socket if disabled' do
      Metricsd.disable!
      @socket.should_not_receive(:send)
      Metricsd::Client.record_value('custom.metric', 5)
    end

    it 'should create and cache UDPSocket in collector_socket method' do
      Metricsd::Client.unstub!(:collector_socket)
      sock = Metricsd::Client.send(:collector_socket)
      sock.should be_a(UDPSocket)
      Metricsd::Client.send(:collector_socket).should be(sock)
    end
  end

  describe '.record_hit' do
    it 'should send two metrics in a single packet' do
      @socket.should_receive(:send).with('all@custom.metric.status:1;all@custom.metric.time:450', 0)
      Metricsd::Client.record_hit('custom.metric', true, 0.45)
    end

    it 'should handle is_success=false' do
      @socket.should_receive(:send).with('all@custom.metric.status:-1;all@custom.metric.time:450', 0)
      Metricsd::Client.record_hit('custom.metric', false, 0.45)
    end

    it 'should apply group to both the metrics' do
      @socket.should_receive(:send).with('all@test.custom.metric.status:1;all@test.custom.metric.time:450', 0)
      Metricsd::Client.record_hit('custom.metric', true, 0.45, :group => 'test')
    end

    it 'should apply source if empty string passed' do
      @socket.should_receive(:send).with('test@custom.metric.status:1;test@custom.metric.time:450', 0)
      Metricsd::Client.record_hit('custom.metric', true, 0.45, :source => '')
    end

    it 'should apply source if specified' do
      @socket.should_receive(:send).with('test2@custom.metric.status:1;test2@custom.metric.time:450', 0)
      Metricsd::Client.record_hit('custom.metric', true, 0.45, :source => 'test2')
    end
  end

  describe '.record_success' do
    it 'should record successes' do
      @socket.should_receive(:send).with('all@custom.metric.status:1', 0)
      Metricsd::Client.record_success('custom.metric')
    end

    it 'should apply group if specified' do
      @socket.should_receive(:send).with('all@test.custom.metric.status:1', 0)
      Metricsd::Client.record_success('custom.metric', :group => 'test')
    end

    it 'should apply source if empty string passed' do
      @socket.should_receive(:send).with('test@custom.metric.status:1', 0)
      Metricsd::Client.record_success('custom.metric', :source => '')
    end

    it 'should apply source specified' do
      @socket.should_receive(:send).with('test2@custom.metric.status:1', 0)
      Metricsd::Client.record_success('custom.metric', :source => 'test2')
    end
  end

  describe '.record_failure' do
    it 'should record failures' do
      @socket.should_receive(:send).with('all@custom.metric.status:-1', 0)
      Metricsd::Client.record_failure('custom.metric')
    end

    it 'should apply group if specified' do
      @socket.should_receive(:send).with('all@test.custom.metric.status:-1', 0)
      Metricsd::Client.record_failure('custom.metric', :group => 'test')
    end

    it 'should apply source if empty string passed' do
      @socket.should_receive(:send).with('test@custom.metric.status:-1', 0)
      Metricsd::Client.record_failure('custom.metric', :source => '')
    end

    it 'should apply source specified' do
      @socket.should_receive(:send).with('test2@custom.metric.status:-1', 0)
      Metricsd::Client.record_failure('custom.metric', :source => 'test2')
    end
  end

  describe '.record_time' do
    it 'should record time if specified' do
      @socket.should_receive(:send).with('all@custom.metric.time:450', 0)
      Metricsd::Client.record_time('custom.metric', 0.45)
    end

    it 'should yield a block if time is not specified' do
      @socket.should_receive(:send).with(match(/all@custom.metric.time:1\d{2}/), 0)
      yielded = false
      Metricsd::Client.record_time('custom.metric') do
        yielded = true
        sleep 0.1
      end
      yielded.should be_true
    end

    it 'should return block value' do
      @socket.should_receive(:send).with(match(/all@custom.metric.time:\d+/), 0)
      Metricsd::Client.record_time('custom.metric') do
        'hello'
      end.should eq('hello')
    end

    it 'should use options if time is not specified' do
      @socket.should_receive(:send).with(match(/all@custom.metric.time:\d+/), 0)
      yielded = false
      Metricsd::Client.record_time('custom.metric', {}) do
        yielded = true
      end
      yielded.should be_true
    end

    it 'should apply group if specified' do
      @socket.should_receive(:send).with('all@test.custom.metric.time:450', 0)
      Metricsd::Client.record_time('custom.metric', 0.45, :group => 'test')
    end

    it 'should apply source if empty string passed' do
      @socket.should_receive(:send).with('test@custom.metric.time:450', 0)
      Metricsd::Client.record_time('custom.metric', 0.45, :source => '')
    end

    it 'should apply source specified' do
      @socket.should_receive(:send).with('test2@custom.metric.time:450', 0)
      Metricsd::Client.record_time('custom.metric', 0.45, :source => 'test2')
    end
  end

  describe '.record_value' do
    it 'should record value' do
      @socket.should_receive(:send).with('all@custom.metric:23', 0)
      Metricsd::Client.record_value('custom.metric', 23)
    end

    it 'should apply group if specified' do
      @socket.should_receive(:send).with('all@test.custom.metric:23', 0)
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

    it 'should apply default group if specified' do
      Metricsd.default_group = 'grp'
      @socket.should_receive(:send).with('all@grp.custom.metric:23', 0)
      Metricsd::Client.record_value('custom.metric', 23)
    end

    it 'should override default group with the specified one' do
      Metricsd.default_group = 'grp'
      @socket.should_receive(:send).with('all@group.custom.metric:23', 0)
      Metricsd::Client.record_value('custom.metric', 23, :group => 'group')
    end

    it 'should clear group, if there is a default one, and empty string specified' do
      Metricsd.default_group = 'grp'
      @socket.should_receive(:send).with('all@custom.metric:23', 0)
      Metricsd::Client.record_value('custom.metric', 23, :group => '')
    end
  end

  describe '.record_values' do
    it 'should record all the values specified' do
      @socket.should_receive(:send).with('all@another.metric:47;all@custom.metric:23', 0)
      Metricsd::Client.record_values({'custom.metric' => 23, 'another.metric' => 47})
    end

    it 'should apply group if specified' do
      @socket.should_receive(:send).with('all@test.another.metric:47;all@test.custom.metric:23', 0)
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
