require "minitest/autorun"
require "mocha/minitest"
require "serverless-tools/deployer/function_config"

module ServerlessTools
  module Deployer
    describe "FunctionConfig" do
      subject do
        FunctionConfig.new(
          name: "example_function_one_v1",
          bucket: "freeagent-lambda-example-scripts",
          s3_archive_name: "function.zip",
          handler_file: "handler_one.rb",
          repo: "serverless-tools"
        )
      end

      it "creates a config class" do
        assert_equal(subject.name, "example_function_one_v1")
        assert_equal(subject.bucket, "freeagent-lambda-example-scripts")
        assert_equal(subject.s3_archive_name, "function.zip")
        assert_equal(subject.handler_file, "handler_one.rb")
        assert_equal(subject.repo, "serverless-tools")
      end
    end
  end
end
