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

        puts "::set-output name=#{response[:function_name]}_status::#{response[:last_update_status]}"
      rescue Aws::Lambda::Errors::ServiceError => e
        puts "::error:: An error occured when updating #{config.name} #{e.message}"
      end

      private

      attr_reader :client, :config
    end
  end
end
