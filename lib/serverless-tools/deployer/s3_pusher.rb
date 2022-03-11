# frozen_string_literal: true

module ServerlessTools
  module Deployer
    class S3Pusher
      def initialize(client:, git:)
        @client = client
        @git = git
      end

      def push(config:)
        object = object(config: config)
        if object.exists?
          puts "Did not upload #{object.key} as it already exists!"
        else
          object.upload_file(config.local_filename)
        end
        object_attributes(object)
      end

      private

      def object_attributes(object)
        {
          s3_bucket: object.bucket.name,
          s3_key: object.key,
        }
      end

      def object(config:)
        Aws::S3::Object.new(
          bucket_name: config.bucket,
          key: config.s3_key(git_sha: git.sha),
          client: client
        )
      end

      attr_reader :client, :git
    end
  end
end
