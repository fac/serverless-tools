# frozen_string_literal: true

module ServerlessTools
  module Deployer
    class DockerBuilder
      def initialize(config:)
        @config = config
      end

      def build
        puts "Building Docker image"
        `docker build . -f #{config.dockerfile} -t #{local_image_name}`
      end

      def output
        {
          local_image_name: local_image_name
        }
      end

      private

      def local_image_name
        "#{config.repo}:latest"
      end

      attr_reader :config
    end
  end
end
