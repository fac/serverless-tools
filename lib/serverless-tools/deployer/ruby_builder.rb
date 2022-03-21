# frozen_string_literal: true

module ServerlessTools
  module Deployer
    class RubyBuilder
      def initialize(config:)
        @config = config
      end

      def build
        `bundle`
        `zip -r "#{local_filename}" #{config.handler_file} lib vendor/`
      end

      def output
        {
          local_filename: local_filename,
        }
      end

      def local_filename
        "#{config.name}.zip"
      end

      private

      attr_reader :config
    end
  end
end
