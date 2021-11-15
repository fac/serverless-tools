require "yaml"

module Deployer
  class AwsLambdaConfig
    attr_reader :function_name, :s3_archive_name, :handler_file, :bucket

    def initialize(filename:, function_name:)
      config_data = YAML.load_file(filename)

      @repo = config_data[function_name]["repo"]
      @function_name = function_name
      @s3_archive_name = config_data[function_name]["s3_archive_name"]
      @handler_file = config_data[function_name]["handler_file"]
      @bucket = config_data[function_name]["bucket"]
    end

    def s3_key
      "#{repo}/deployments/#{git_sha}/#{function_name}/#{s3_archive_name}"
    end

    def local_filename
      "#{function_name}.zip"
    end

    private

    attr_reader :repo

    def git_sha
      (ENV["GITHUB_SHA"] || (`git rev-parse HEAD`)).strip
    end
  end
end
