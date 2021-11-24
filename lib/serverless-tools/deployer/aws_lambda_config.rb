require "yaml"
require_relative "../git"

module ServerlessTools
  module Deployer
    class AwsLambdaConfig
      attr_reader :function_name, :s3_archive_name, :handler_file, :bucket

      def initialize(filename:, function_name:, git: Git.new)
        config_data = YAML.load_file(filename)

        @git = git
        @repo = config_data[function_name]["repo"]
        @function_name = function_name
        @s3_archive_name = config_data[function_name]["s3_archive_name"]
        @handler_file = config_data[function_name]["handler_file"]
        @bucket = config_data[function_name]["bucket"]
      end

      def s3_key
        "#{repo}/deployments/#{git.sha}/#{function_name}/#{s3_archive_name}"
      end

      def local_filename
        "#{function_name}.zip"
      end

      private

      attr_reader :repo, :git
    end
  end
end
