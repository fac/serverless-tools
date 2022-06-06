# frozen_string_literal: true

module ServerlessTools
  module Deployer
    class LambdaUpdater
      def initialize(client:, config:)
        @client = client
        @config = config
      end

      def update(options)
        options[:function_name] = config.name

        response = client.update_function_code(options)

        success = client.wait_until(:function_updated,
          { function_name: response[:function_name] },
          { max_attempts: 10, delay: 3 }
        )

        log_output(options: options, success: success)

        success
      rescue Aws::Lambda::Errors::ServiceError, Aws::Waiters::Errors => e
        puts "::error:: An error occured when updating #{config.name} #{e.message}"
        log_output(options: options, success: false)

        false
      end

      private

      def log_output(options:, success:)
        puts "::set-output name=#{options[:function_name]}_status::#{success ? "Successful" : "Failed" }"
      end

      attr_reader :client, :config
    end
  end
end
