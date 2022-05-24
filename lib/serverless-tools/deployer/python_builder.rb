require "fileutils"
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
        `poetry build`
        # Workaround is installing them using pip to specified "lambda-package" target directory
        `python -m pip install -t lambda-package dist/*.whl`
        # Zipping lambda-package folder with the handler file in a zip as required by AWS
        `zip -jr "#{local_filename}" #{config.handler_file}`
        `cd lambda-package && zip -r "../#{local_filename}" ./*`
        # Clean up
        clean
      end

      def output
        {
          local_filename: local_filename,
        }
      end

      def local_filename
        "#{config.name}.zip"
      end

      # Remove build residue artifacts
      def clean
        FileUtils.remove_dir("./lambda-package",true)
        FileUtils.remove_dir("./dist",true)
      end

      private

      attr_reader :config
    end
  end
end
