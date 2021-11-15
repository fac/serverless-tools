require "minitest/autorun"
require "mocha/minitest"
require "serverless-tools/deployer/aws_lambda_config"

describe "AwsLambdaConfig" do
  subject do
    ServerlessTools::Deployer::AwsLambdaConfig.new(
      filename: "test/fixtures/functions.yml",
      function_name: "example_function_one_v1"
    )
  end

  it "loads the correct config for a lambda function" do
    assert_equal(subject.function_name, "example_function_one_v1")
    assert_equal(subject.s3_archive_name, "function.zip")
    assert_equal(subject.handler_file, "handler_one.rb")
    assert_equal(subject.bucket, "freeagent-lambda-example-scripts")
  end

  describe "#key" do
    it "generates the expected s3 key for a lambda function" do
      # git_sha shells out to get the current sha, for this test we assume
      # that it always gets the correct sha so we mock it out with a known value
      subject.expects(:git_sha).returns("1234567890")
      assert_equal(
        "serverless-tools/deployments/1234567890/example_function_one_v1/function.zip",
        subject.s3_key
      )
    end
  end

  describe "#local_filename" do
    it "generates the correct name for the local zip archive" do
      assert_equal(
        "example_function_one_v1.zip",
        subject.local_filename
      )
    end
  end
end
