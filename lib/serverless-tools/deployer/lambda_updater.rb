# frozen_string_literal: true

module ServerlessTools
  module Deployer
    class LambdaUpdater
      def initialize(pusher:, client:)
        @client = client
        @pusher = pusher
      end

      def update(config:)
        remote_assets = pusher.push(config: config)
        remote_assets[:function_name] = config.name

        response = client.update_function_code(remote_assets)

        puts "::set-output name=#{response[:function_name]}_status::#{response[:last_update_status]}"
      rescue Aws::Lambda::Errors::ServiceError => e
        puts "::error:: An error occured when updating #{config.name} #{e.message}"
      end

      private

      attr_reader :pusher, :client
    end
  end
end
