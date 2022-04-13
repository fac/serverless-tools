# fronzen_string_literal: true

require "aws-sdk-s3"
require "aws-sdk-ecr"
require "aws-sdk-lambda"

require_relative "../git"
require_relative "./s3_pusher"
require_relative "./ecr_pusher"
require_relative "./lambda_updater"
require_relative "./ruby_builder"
require_relative "./r_builder"
require_relative "./errors"

module ServerlessTools
  module Deployer
    class FunctionDeployer
      attr_reader :builder, :pusher, :updater

      def initialize(builder:, pusher:, updater:)
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
        updater.update(pusher.output)
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
        self.new(
          builder: RubyBuilder.new(config: config),
          pusher: S3Pusher.new(client: Aws::S3::Client.new, git: Git.new, config: config),
          updater: LambdaUpdater.new(client: Aws::Lambda::Client.new, config: config)
        )
      end

      def self.r_deployer(config)
        self.new(
          builder: RBuilder.new(config: config),
          pusher: EcrPusher.new(client: Aws::ECR::Client.new, git: Git.new, config: config),
          updater: LambdaUpdater.new(client: Aws::Lambda::Client.new, config: config)
        )
      end
    end
  end
end