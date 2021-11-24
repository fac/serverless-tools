require "aws-sdk-lambda"

module ServerlessTools
  module Deployer
    class AwsLambdaFunction
      def initialize(config, client:)
        @config = config
        @client = client
      end

      def update_code(object)
        unless object.exists?
          puts "::warning:: Not updating #{config.function_name} as key does not exist!"
          puts "::warning:: key: #{object.key}"
          return
        end
        resp = client.update_function_code({
          function_name: config.function_name,
          s3_bucket: object.bucket.name,
          s3_key: object.key,
        })
        puts "::set-output name=#{resp[:function_name]}_status::#{resp[:last_update_status]}"
        puts "::set-output name=#{resp[:function_name]}_key::#{object.key}"
      rescue Aws::Lambda::Errors::ServiceError => e
        puts "::error:: An error occured when updating #{config.function_name} #{e.message}"
      end

      private

      attr_reader :config, :client
    end
  end
end
