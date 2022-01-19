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

      describe "#key" do
        it "generates the expected s3 key for a lambda function" do
          assert_equal(
            "serverless-tools/deployments/1234567890/example_function_one_v1/function.zip",
            subject.s3_key(git_sha: "1234567890")
          )
        end
      end

      describe "#local_filename" do
        it "generates the correct name for the local zip archive" do
          assert_equal("example_function_one_v1.zip", subject.local_filename)
        end
      end
    end
  end
end
