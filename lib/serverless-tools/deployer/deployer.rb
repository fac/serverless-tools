# fronzen_string_literal: true

require "aws-sdk-s3"
require "aws-sdk-lambda"

require_relative "./s3_pusher.rb"
require_relative "./lambda_updater.rb"
require_relative "../git"

module ServerlessTools
  module Deployer
    class Deployer
      attr_reader :config, :pusher, :updater

      def initialize(config, pusher:, updater:)
        @config = config
        @pusher = pusher
        @updater = updater
      end

      def build
        `zip -r "#{config.local_filename}" #{config.handler_file} lib vendor/`
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

      def self.create_for_function(config:)
        pusher = S3Pusher.new(client: Aws::S3::Client.new, git: Git.new)
        self.new(
          config,
          pusher: pusher,
          updater: LambdaUpdater.new(pusher: pusher, client: Aws::Lambda::Client.new)
        )
      end
    end
  end
end
