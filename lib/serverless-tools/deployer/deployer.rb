# fronzen_string_literal: true

require "aws-sdk-s3"
require "aws-sdk-lambda"

require_relative "../git"
require_relative "./s3_pusher"
require_relative "./lambda_updater"
require_relative "./ruby_builder"
require_relative "./errors"

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
        builder.build
      end

      def push
        pusher.push(**builder.output)
      end

      def update
        updater.update(config: config)
      end

      def deploy
        build
        push
        update
      end

      def self.create_for_function(config:)
        send("#{config.runtime}_deployer", config)
      rescue NoMethodError
        raise RuntimeNotSupported.new(config: config)
      end

      def self.ruby_deployer(config)
        pusher = S3Pusher.new(client: Aws::S3::Client.new, git: Git.new, config: config)
        self.new(
          config,
          builder: RubyBuilder.new(config: config),
          pusher: pusher,
          updater: LambdaUpdater.new(pusher: pusher, client: Aws::Lambda::Client.new)
        )
      end
    end
  end
end
