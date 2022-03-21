# frozen_string_literal: true

require "aws-sdk-s3"

module ServerlessTools
  module Deployer
    class S3Pusher
      def initialize(client:, git:, config:)
        @client = client
        @git = git
        @config = config
      end

      def push(local_filename:)
        if object.exists?
          puts "Did not upload #{object.key} as it already exists!"
        else
          object.upload_file(local_filename)
        end
        output
      end

      def output
        return {} unless object.exists?
        {
          s3_bucket: object.bucket.name,
          s3_key: object.key,
        }
      end

      private

      def object
        @object ||= Aws::S3::Object.new(
          bucket_name: config.bucket,
          key: s3_key,
          client: client
        )
      end

      def s3_key
        "#{config.repo}/deployments/#{git.sha}/#{config.name}/#{config.s3_archive_name}"
      end

      attr_reader :client, :git, :config
    end
  end
end
