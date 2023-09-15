require "logger"

module ServerlessTools
  module Logging
    class << self
      def logger
        return @logger if defined? @logger

        @logger = Logger.new(STDOUT)
        @logger.level = ENV["SERVERLESS_TOOLS_LOG_LEVEL"] || :info
        @logger
      end
    end
  end
end
