# fronzen_string_literal: true

require "aws-sdk-s3"
require "aws-sdk-ecr"
require "aws-sdk-lambda"

require_relative "../git"
require_relative "./s3_pusher"
require_relative "./ecr_pusher"
require_relative "./lambda_updater"
require_relative "./ruby_builder"
require_relative "./docker_builder"
require_relative "./python_builder"
require_relative "./errors"
require_relative "./overrides"

module ServerlessTools
  module Deployer
    class FunctionDeployer
      attr_reader :builder, :pusher, :updater, :overrides

      def initialize(builder:, pusher:, updater:, overrides:)
        @builder = builder
        @pusher = pusher
        @updater = updater
        @overrides = overrides
      end

      def build
        builder.build
      end

      def push
        pusher.push(**builder.output) if pusher_should_push?
      end

      def update
        updater.update(pusher.output)
      end

      def deploy
        build
        push
        update
      end

      private

      def pusher_should_push?
        return true if overrides.force?
        pusher.output.empty?
      end

      def self.create_for_function(config:, overrides: Overrides.new)
        send("#{config.runtime}_deployer", config, overrides)
      rescue NoMethodError
        raise RuntimeNotSupported.new(config: config)
      end

      def self.ruby_deployer(config, overrides)
        self.new(
          builder: RubyBuilder.new(config: config),
          pusher: S3Pusher.new(client: Aws::S3::Client.new, git: Git.new, config: config),
          updater: LambdaUpdater.new(client: Aws::Lambda::Client.new, config: config),
          overrides: overrides,
        )
      end

      def self.docker_deployer(config, overrides)
        self.new(
          builder: DockerBuilder.new(config: config),
          pusher: EcrPusher.new(client: Aws::ECR::Client.new, git: Git.new, config: config),
          updater: LambdaUpdater.new(client: Aws::Lambda::Client.new, config: config),
          overrides: overrides,
        )
      end

      def self.python_deployer(config)
        self.new(
          builder: PythonBuilder.new(config: config),
          pusher: S3Pusher.new(client: Aws::S3::Client.new, git: Git.new, config: config),
          updater: LambdaUpdater.new(client: Aws::Lambda::Client.new, config: config)
        )
      end
    end
  end
end
