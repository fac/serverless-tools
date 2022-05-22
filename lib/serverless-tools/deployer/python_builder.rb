# frozen_string_literal: true

module ServerlessTools
  module Deployer
    class PythonBuilder
      def initialize(config:)
        @config = config
      end
      # Run three commands to build the python bundle for Lambda
      def build
        # Poetry does not have an option to install dependencies to a specified target folder.
        # Workaround is generating a requirments.txt file using poetry
        `poetry export -f requirements.txt --without-hashes > requirements.txt`
        # And then installing them using pip to specified "bundle" target directory
        `pip install -r requirements.txt -t ./bundle/`
        # Zipping contents of functions and bundle folders with the
        # handler file in a zip as required by AWS
        `zip -r "#{local_filename}" #{config.handler_file} src functions`
        `cd bundle && zip -r "../#{local_filename}" ./*`
      end

      def output
        {
          local_filename: local_filename,
        }
      end

      def local_filename
        "#{config.name}.zip"
      end

      private

      attr_reader :config
    end
  end
end
