# frozen_string_literal: true

require_relative "./system_call"

module ServerlessTools
  module Deployer
    class DockerBuilder
      include SystemCall

      def initialize(config:)
        @config = config
      end

      def build
        system_call "docker build . -f #{config.dockerfile} -t #{local_image_name} #{platform}".rstrip
      end

      def output
        {
          local_image_name: local_image_name
        }
      end

      private

      def platform
        return unless config.platform
        "--platform #{config.platform}"
      end

      def local_image_name
        "#{config.repo}:latest"
      end

      attr_reader :config
    end
  end
end
