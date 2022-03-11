# fronzen_string_literal: true

require "aws-sdk-s3"
require "aws-sdk-lambda"

require_relative "./s3_pusher"
require_relative "./lambda_updater"
require_relative "./ruby_builder"
require_relative "../git"

module ServerlessTools
  module Deployer
    class Deployer
      attr_reader :config, :builder, :pusher, :updater

      def initialize(config, builder:, pusher:, updater:)
        @config = config
        @builder = builder
        @pusher = pusher
        @updater = updater
      end

      def build
        builder.build(config: config)
      end

      def push
        pusher.push(config: config)
      end

      def update
        updater.update(config: config)
      end

      def deploy
        build
        push
        update
      end

      # Create for function should assemble the deployer
      # based on the config. Here the assumed configuration
      # for a ruby lambda with the assets in S3.
      def self.create_for_function(config:)
        pusher = S3Pusher.new(client: Aws::S3::Client.new, git: Git.new)
        self.new(
          config,
          builder: RubyBuilder.new(),
          pusher: pusher,
          updater: LambdaUpdater.new(pusher: pusher, client: Aws::Lambda::Client.new)
        )
      end
    end
  end
end
