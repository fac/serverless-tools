# frozen_string_literal: true

module ServerlessTools
  module Deployer
    class LambdaUpdater
      def initialize(client:, config:)
        @client = client
        @config = config
      end

      def update(options)
        update_options = {
          **options,
          function_name: config.name,
          publish: true,
        }

        response = client.update_function_code(update_options)

        client.wait_until(:function_updated,
          { function_name: response[:function_name] },
          { max_attempts: 10, delay: 3 }
        )

        update_options
      end

      private

      attr_reader :client, :config
    end
  end
end
