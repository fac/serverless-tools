# frozen_string_literal: true

require_relative "./system_call"

module ServerlessTools
  module Deployer
    class RubyBuilder
      include SystemCall

      def initialize(config:)
        @config = config
      end

      def build
        system_call "bundle"
        system_call "zip -r \"#{local_filename}\" #{config.handler_file} lib vendor/"
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
