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

module ServerlessTools
  module Deployer
    class FunctionDeployer
      attr_reader :builder, :pusher, :updater, :options, :config, :running_in_github

      # rubocop:disable  Metrics/ParameterLists
      def initialize(builder:, pusher:, updater:, options:, config:, in_github: ENV.fetch("GITHUB_ENV", ""))
        @builder = builder
        @pusher = pusher
        @updater = updater
        @options = options
        @config = config
        @running_in_github = !in_github.empty?
      end
      # rubocop:enable  Metrics/ParameterLists

      def build
        builder.build
        puts "    📦 Assets built"
      end

      def push
        unless pusher_should_push?
          puts("    🛑 Assets have not been updated")
          return
        end
        pusher.push(**builder.output)
        puts "    ⬆️  Assets pushed"
      end

      def update
        response = updater.update(pusher.output)
        puts "    ✅ Sucessfully updated"
        log_github_output(response) if running_in_github
      rescue Aws::Lambda::Errors::ServiceError, Aws::Waiters::Errors
        puts "    ❌ Failed to update"
        log_github_error if running_in_github
      end

      def deploy
        puts "🚢 Deploying #{config.name}..."
        build
        push
        update
      end

      private

      def log_github_output(response)
        puts("echo \"#{response[:function_name]}_status=Success\" >> \"$GITHUB_OUTPUT\"")
      end

      def log_github_error
       puts("echo \"#{config.name}_status=Failed\" >> \"$GITHUB_OUTPUT\"")
      end

      def pusher_should_push?
        return true if options.force?
        pusher.output.empty?
      end

      def self.create_for_function(config:, options:)
        send("#{config.runtime}_deployer", config, options)
      rescue NoMethodError
        raise RuntimeNotSupported.new(config: config)
      end

      def self.ruby_deployer(config, options)
        self.new(
          builder: RubyBuilder.new(config: config),
          pusher: S3Pusher.new(client: Aws::S3::Client.new, git: Git.new, config: config),
          updater: LambdaUpdater.new(client: Aws::Lambda::Client.new, config: config),
          options: options,
          config: config,
        )
      end

      def self.docker_deployer(config, options)
        self.new(
          builder: DockerBuilder.new(config: config),
          pusher: EcrPusher.new(client: Aws::ECR::Client.new, git: Git.new, config: config),
          updater: LambdaUpdater.new(client: Aws::Lambda::Client.new, config: config),
          options: options,
          config: config,
        )
      end

      def self.python_deployer(config, options)
        self.new(
          builder: PythonBuilder.new(config: config),
          pusher: S3Pusher.new(client: Aws::S3::Client.new, git: Git.new, config: config),
          updater: LambdaUpdater.new(client: Aws::Lambda::Client.new, config: config),
          options: options,
          config: config,
        )
      end
    end
  end
end
