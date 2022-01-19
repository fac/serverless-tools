require "aws-sdk-s3"

require_relative "./s3_uploader.rb"
require_relative "./aws_lambda_function.rb"
require_relative "../git"

module ServerlessTools
  module Deployer
    class Deployer
      def initialize(config, s3_client: Aws::S3::Client.new, lambda_client: Aws::Lambda::Client.new, git: Git.new)
        @config = config
        @s3_client = s3_client
        @lambda_client = lambda_client
        @git = git
      end

      def build
        `zip -r "#{config.local_filename}" #{config.handler_file} lib vendor/`
      end

      def push
        S3Uploader.new(object).upload(config.local_filename)
      end

      def update
        AwsLambdaFunction.new(config, client: lambda_client).update_code(object)
      end

      def deploy
        build
        push
        update
      end

      private

      def object
        Aws::S3::Object.new(
          bucket_name: config.bucket,
          key: config.s3_key(git_sha: git.sha),
          client: s3_client
        )
      end

      attr_reader :config, :s3_client, :lambda_client, :git
    end
  end
end
