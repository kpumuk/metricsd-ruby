require 'bundler/setup'
require 'metricsd'

describe Metricsd do
  after :each do
    Metricsd.reset_defaults!
  end

  context 'with defaults' do
    source = Socket.gethostname.split('.').first

    it 'should have server_host = 127.0.0.1' do
      Metricsd.server_host.should == '127.0.0.1'
    end

    it 'should have server_port = 6311' do
      Metricsd.server_port.should == 6311
    end

    it "should have source = #{source}" do
      Metricsd.source.should == source
    end

    it 'should have default_source = all' do
      Metricsd.default_source.should == 'all'
    end

    it 'should create logger' do
      Metricsd.logger.should be_a(Logger)
    end
  end

  context 'setters' do
    it 'should allow to change server_host' do
      Metricsd.server_host = 'metrics.local'
      Metricsd.server_host.should == 'metrics.local'
    end

    it 'should allow to change server_port' do
      Metricsd.server_port = '8000'
      Metricsd.server_port.should == 8000
    end

    it 'should not allow invalid server_port' do
      expect {
        Metricsd.server_port = 'aaa'
      }.to raise_error
    end

    it 'should allow to change source' do
      Metricsd.source = 'test-host'
      Metricsd.source.should == 'test-host'
    end

    it 'should allow to change default_source' do
      Metricsd.default_source = 'nothing'
      Metricsd.default_source.should == 'nothing'
    end

    it 'should allow to change logger' do
      mock = Metricsd.logger = mock('Logger')
      Metricsd.logger.should be(mock)
    end
  end
end