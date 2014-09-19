require 'spec_helper'
require 'benchmark'

module Palmade::Tapsilog
  module Speedtest
    TAPSILOG_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../../../'))

    describe 'Speedtest' do
      before :all do
        @levels = [
          'debug',
          'error',
          'fatal',
          'info',
          'warn'
        ]

        FileUtils.rm_rf('/tmp/tapsilog_test')
        Dir.mkdir('/tmp/tapsilog_test')

        $stderr = StringIO.new

        unless @pid = fork
          exec("#{TAPSILOG_ROOT}/bin/tapsilog start -c #{TAPSILOG_ROOT}/spec/palmade/config/tapsilog.yml")
        end

        sleep 1
      end

      it 'should run speedtest' do
        speedtest('short messages','0123456789')
        speedtest('larger messages','0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789')
        logger_speedtest('short messages','0123456789')
        logger_speedtest('larger messages','0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789')
      end

      it "should cleanup" do
        unless pid = fork
          exec("#{TAPSILOG_ROOT}/bin/tapsilog stop -c #{TAPSILOG_ROOT}/spec/palmade/config/tapsilog.yml")
        end

        sleep(1)
        expect(File.exists?("/tmp/tapsilog_test.pid")).to be false
        expect(File.exists?("/tmp/tapsilog_test.sock")).to be false
      end

      def speedtest(label, message)
        puts "Tapsilog Speedtest -- #{label}"

        logger = Palmade::Tapsilog::Logger.new('speedtest', '127.0.0.1:19100', 'tapsilog_key')
        lvl    = 'info'

        puts "Testing 100000 messages of #{message.length} bytes each."

        start = total = nil

        Benchmark.bm do |bm|
          bm.report do
            start = Time.now;
            100000.times { logger.log(lvl,message) };
            total = Time.now - start
          end
        end

        rate  = 100000 / total
        puts "\nMessage rate: #{rate}/second (#{total})\n\n"
      end

      def logger_speedtest(label,message)
        puts "Ruby Logger Speedtest -- #{label}"
        puts "Testing 100000 messages of #{message.length} bytes each."

        logger = ::Logger.new('/tmp/tapsilog_test/logger_speedtest')

        start = total = nil

        Benchmark.bm do |bm|
          bm.report do
            start = Time.now;
            100000.times { logger.info(message) };
            total = Time.now - start
          end
        end

        rate = 100000 / total
        puts "\nMessage rate: #{rate}/second (#{total})\n\n"
        logger.close
      end
    end
  end
end
