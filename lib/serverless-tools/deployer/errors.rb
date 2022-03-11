# frozen_string_literal: true

module ServerlessTools
  module Deployer
    class RuntimeNotSupported < RuntimeError
      def initialize(config:)
        super("Could not infer lambda runtime from #{config}")
      end
    end

    class ConfigFileNotFound < RuntimeError
      def initialize(filename:)
        super("Could not find config file '#{filename}'")
      end
    end

    class FunctionConfigNotFound < RuntimeError
      def initialize(function_name:, filename:)
        super("Could not find the config for function '#{function_name}' in '#{filename}'")
      end
    end
  end
end
