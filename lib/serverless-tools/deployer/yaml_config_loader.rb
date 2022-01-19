# frozen_string_literal: true
require "yaml"
require_relative "./errors"
require_relative "./function_config"

module ServerlessTools
  module Deployer
    class YamlConfigLoader
      attr_reader :data, :filename

      def initialize(filename:)
        @data = YAML.load_file(filename)
        @filename = filename

      rescue Errno::ENOENT
        raise ConfigFileNotFound.new(filename: filename)
      end

      def functions
        @keys ||= @data.keys
      end

      def lambda_config(function_name:)
        FunctionConfig.new(
          name: function_name,
          **@data.fetch(function_name)
        )

      rescue KeyError
        raise FunctionConfigNotFound.new(
          function_name: function_name,
          filename: @filename,
        )
      end
    end
  end
end
