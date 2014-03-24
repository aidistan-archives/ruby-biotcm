# encoding: UTF-8
require 'logger'

module BioTCM
  # A double-output featured logger.
  # Call {instance} to return the singleton instance and use it 
  # as if it's a {http://rubydoc.info/stdlib/logger/Logger stdlib Logger}.
  class Logger    
    # Instance methods not in this list will be undefined at the beginning of
    # class definition
    PRESERVED = [:__id__, :__send__, :object_id, :respond_to?]
    instance_methods.each do |m|
      next if PRESERVED.include?(m)
      undef_method m
    end

    # Get the logger linked to STDOUT
    # @return [::Logger]
    attr_reader :screen_logger
    # Get the logger linked to file
    # @return [::Logger]
    attr_reader :file_logger

    # Get the instance of {Logger}
    # @param log_file_path [String] path to your log file
    def self.instance(log_file_path)
      @instance or @instance = new(log_file_path)
    end

    # @private
    def inspect
      "#<Bioinfo::Logger.instance>"
    end
    # @private
    def to_s
      inspect
    end
    #
    def respond_to?(sym)
      return true if super(sym)
      return @screen_logger.respond_to?(sym)
    end

    private

    def initialize(log_file_path)
      # Screen
      @screen_logger = ::Logger.new(STDOUT)
      @screen_logger.level = ::Logger::INFO
      @screen_logger.formatter = proc { |severity, datetime, progname, msg|
        ['%7s' % "[#{severity}]", datetime.strftime('%H:%M:%S'), progname.to_s+':', msg].join(' ') + "\n"
      }
      # File
      @file_logger = ::Logger.new(log_file_path)
      @file_logger.level = ::Logger::DEBUG
      @file_logger.datetime_format = '%Y-%m-%d %H:%M:%S.%6N '
    end
    # Transmit method call if std-lib Logger can respond to it
    def method_missing(symbol, *args, &block)
      super unless @screen_logger.respond_to?(symbol)
      if block
        @screen_logger.send(symbol, *args, &block)
        @file_logger.send(symbol, *args, &block)
      else
        @screen_logger.send(symbol, *args)
        @file_logger.send(symbol, *args)
      end
    end
  end
end
