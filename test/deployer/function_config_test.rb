require "minitest/autorun"
require "mocha/minitest"
require "serverless-tools/deployer/function_config"

module ServerlessTools
  module Deployer
    describe "FunctionConfig" do
      let(:s3_archive_function_config) do
        FunctionConfig.new(
          name: "example_function_one_v1",
          bucket: "freeagent-lambda-example-scripts",
          s3_archive_name: "function.zip",
          handler_file: "handler_one.rb",
          repo: "serverless-tools"
        )
      end

      let(:containerised_function_config) do
        FunctionConfig.new(
          name: "example_function_two_v1",
          dockerfile: "./lambda-context/Dockerfile",
          handler_file: "handler_two.R",
          repo: "serverless-tools"
        )
      end

      it "creates a config for S3-based functions" do
        assert_equal(s3_archive_function_config.name, "example_function_one_v1")
        assert_equal(s3_archive_function_config.bucket, "freeagent-lambda-example-scripts")
        assert_equal(s3_archive_function_config.s3_archive_name, "function.zip")
        assert_equal(s3_archive_function_config.handler_file, "handler_one.rb")
        assert_equal(s3_archive_function_config.repo, "serverless-tools")
      end

      it "creates a config for container-based functions" do
        assert_equal(containerised_function_config.name, "example_function_two_v1")
        assert_equal(containerised_function_config.dockerfile, "./lambda-context/Dockerfile")
        assert_equal(containerised_function_config.handler_file, "handler_two.R")
        assert_equal(containerised_function_config.repo, "serverless-tools")
      end

      describe "#runtime" do
        it "infers a runtime based on the config" do
          assert_equal(s3_archive_function_config.runtime, "ruby")
          assert_equal(containerised_function_config.runtime, "r")
        end
      end
    end
  end
end
