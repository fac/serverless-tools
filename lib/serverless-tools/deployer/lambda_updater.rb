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

        client.wait_until(:function_updated,
          { function_name: response[:function_name] },
          { max_attempts: 10, delay: 3 }
        )

        options
      end

      private

      attr_reader :client, :config
    end
  end
end
