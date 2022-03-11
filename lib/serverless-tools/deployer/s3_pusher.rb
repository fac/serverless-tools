# frozen_string_literal: true

module ServerlessTools
  module Deployer
    class S3Pusher
      def initialize(client:, builder:, git:)
        @client = client
        @builder = builder
        @git = git
      end

      def push(config:)
        object = object(config: config)
        if object.exists?
          puts "Did not upload #{object.key} as it already exists!"
        else
          object.upload_file(builder.local_filename(config))
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
          key: s3_key(config: config),
          client: client
        )
      end

      def s3_key(config:)
        "#{config.repo}/deployments/#{git.sha}/#{config.name}/#{config.s3_archive_name}"
      end

      attr_reader :client, :builder, :git
    end
  end
end
