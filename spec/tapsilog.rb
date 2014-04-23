require "spec_helper"
require "fileutils"
require "logger"
require "benchmark"

TAPSILOG_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

describe "Tapsilog" do

  before :all do
    @levels = [ 'debug', 'info', 'warn', 'error', 'fatal' ]
    FileUtils.rm_rf('/tmp/tapsilog_test')
    Dir.mkdir('/tmp/tapsilog_test')
    $stderr = StringIO.new

    unless @pid = fork
      exec("#{TAPSILOG_ROOT}/bin/tapsilog start -c #{TAPSILOG_ROOT}/spec/config/tapsilog.yml")
    end
    sleep 1
  end

  it "should write correct pid" do
    File.exists?("/tmp/tapsilog_test.pid").should == true
    File.read("/tmp/tapsilog_test.pid").chomp.should == @pid.to_s
  end

  it "should accept TCP messages" do
    logger = Palmade::Tapsilog::Logger.new('tcp_logs', '127.0.0.1:19100', 'tapsilog_key')
    @levels.each do |level|
      logger.log(level, 'abc123')
    end
    sleep 1

    File.exists?('/tmp/tapsilog_test/tcp_logs').should == true

    log_file = File.read('/tmp/tapsilog_test/tcp_logs')

    index = 0
    log_file.each_line do |log_message|
      log_message.should =~ /#{@levels[index]}|abc123$/
      index += 1
    end
  end

  it "should accept TCP messages with tags" do
    logger = Palmade::Tapsilog::Logger.new('tcp_logs_with_tags', '127.0.0.1:19100', 'tapsilog_key')
    @levels.each do |level|
      logger.log(level, 'abc123withtag', :tag => 'tag_message')
    end
    sleep 1

    File.exists?('/tmp/tapsilog_test/tcp_logs_with_tags').should == true

    log_file = File.read('/tmp/tapsilog_test/tcp_logs_with_tags')

    index = 0
    log_file.each_line do |log_message|
      log_message.should =~ /#{@levels[index]}|abc123|tag=tag_message$/
      index += 1
    end
  end

  it "should accept Unix socket messages" do
    logger = Palmade::Tapsilog::Logger.new('unix_logs', '/tmp/tapsilog_test.sock', 'tapsilog_key')
    @levels.each do |level|
      logger.log(level, 'abc123')
    end
    sleep 1

    File.exists?('/tmp/tapsilog_test/unix_logs').should == true

    log_file = File.read('/tmp/tapsilog_test/unix_logs')

    index = 0
    log_file.each_line do |log_message|
      log_message.should =~ /#{@levels[index]}|abc123$/
      index += 1
    end

  end

  it "should accept Unix socket messages with tags" do
    logger = Palmade::Tapsilog::Logger.new('unix_logs_with_tags', '/tmp/tapsilog_test.sock', 'tapsilog_key')
    @levels.each do |level|
      logger.log(level, 'abc123withtag', :tag => 'tag_message')
    end
    sleep 1

    File.exists?('/tmp/tapsilog_test/unix_logs_with_tags').should == true

    log_file = File.read('/tmp/tapsilog_test/unix_logs_with_tags')

    index = 0
    log_file.each_line do |log_message|
      log_message.should =~ /#{@levels[index]}|abc123|tag=tag_message$/
      index += 1
    end
  end

  it "should reject unauthenticated log messages" do
    logger = Palmade::Tapsilog::Logger.new('unauthenticated_logs', '/tmp/tapsilog_test.sock', 'wrong_key')
    @levels.each do |level|
      logger.log(level, 'abc123withtag', :tag => 'tag_message')
    end

    File.exists?('/tmp/tapsilog_test/unauthenticated_logs').should == false
  end

  it "should run speedtest" do
    speedtest('short messages','0123456789')
    speedtest('larger messages','0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789')
    logger_speedtest('short messages','0123456789')
    logger_speedtest('larger messages','0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789')
  end

  it "should cleanup" do
    unless pid = fork
      exec("#{TAPSILOG_ROOT}/bin/tapsilog stop -c #{TAPSILOG_ROOT}/spec/config/tapsilog.yml")
    end

    sleep(1)
    File.exists?("/tmp/tapsilog_test.pid").should == false
    File.exists?("/tmp/tapsilog_test.sock").should == false
  end

  def speedtest(label, message)
    puts "Tapsilog Speedtest -- #{label}"
    logger = Palmade::Tapsilog::Logger.new('speedtest', '127.0.0.1:19100', 'tapsilog_key')
    lvl = 'info'
    puts "Testing 100000 messages of #{message.length} bytes each."
    start = total = nil
    Benchmark.bm do |bm|
      bm.report { start = Time.now; 100000.times { logger.log(lvl,message) }; total = Time.now - start}
    end
    total = Time.now - start
    rate = 100000 / total
    puts "\nMessage rate: #{rate}/second (#{total})\n\n"
  end

  def logger_speedtest(label,message)
    puts "Ruby Logger Speedtest -- #{label}"
    puts "Testing 100000 messages of #{message.length} bytes each."
    logger = Logger.new('/tmp/tapsilog_test/logger_speedtest')
    start = total = nil
    Benchmark.bm do |bm|
      bm.report { start = Time.now; 100000.times { logger.info(message) }; total = Time.now - start}
    end
    rate = 100000 / total
    puts "\nMessage rate: #{rate}/second (#{total})\n\n"
    logger.close
  end

end
