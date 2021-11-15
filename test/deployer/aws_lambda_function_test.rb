require "minitest/autorun"
require "mocha/minitest"
require "aws-sdk-s3"

require "serverless-tools/deployer/aws_lambda_function"

describe "AwsLambdaFunction" do
  let(:lambda_client) { Aws::Lambda::Client.new(stub_responses: true) }

  let(:function_name) { "example_function_one_v1" }
  let(:key) { "serverless-tools/deployments/1234567890/#{function_name}/function.zip" }

  let(:config) do
    ServerlessTools::Deployer::AwsLambdaConfig.new(
      filename: "test/fixtures/functions.yml",
      function_name: function_name
    )
  end

  let(:object) { mock }
  let(:bucket) { mock }

  describe "#update_code" do
    before do
      config.stubs(:git_sha).returns("1234567890")
      object.stubs(:key).returns(config.s3_key)
      object.stubs(:bucket).returns(bucket)
      bucket.stubs(:name).returns(config.bucket)
    end

    it "updates lambda code if code object exists" do
      object.expects(:exists?).returns(true)

      lambda_client
        .expects(:update_function_code)
        .with(
          has_entries(
            s3_bucket: "freeagent-lambda-example-scripts",
            s3_key: key
          )
        ).returns({ function_name: function_name, last_update_status: "Successful" })

      lambda_function = ServerlessTools::Deployer::AwsLambdaFunction.new(config, client: lambda_client)

      lambda_function.expects(:puts).with("")
      lambda_function.expects(:puts).with("::set-output name=#{function_name}::Successful")
      lambda_function.expects(:puts).with("\\`#{function_name}\\` function update was Successful")
      lambda_function.expects(:puts).with("> updated with #{key}")

      lambda_function.update_code(object)
    end

    it "does not update lambda code if code object does not exist" do
      object.expects(:exists?).returns(false)

      lambda_client.expects(:update_function_code).never

      lambda_function = ServerlessTools::Deployer::AwsLambdaFunction.new(config, client: lambda_client)

      lambda_function.expects(:puts).with("")
      lambda_function.expects(:puts).with("::warning:: Not updating #{function_name} as key does not exist!")
      lambda_function.expects(:puts).with("::warning:: key: #{key}")

      lambda_function.update_code(object)
    end

    describe "when the call to update the function code raises an error" do
      it "logs the error message" do
        object.expects(:exists?).returns(true)

        lambda_client
          .expects(:update_function_code)
          .raises(Aws::Lambda::Errors::InvalidParameterValueException.new("", "Error"))

        lambda_function = ServerlessTools::Deployer::AwsLambdaFunction.new(config, client: lambda_client)

        lambda_function.expects(:puts).with("")
        lambda_function.expects(:puts).with("::error:: An error occured when updating #{function_name} Error")
        lambda_function.expects(:puts).with("An error occured when updating \\`#{function_name}\\`")
        lambda_function.expects(:puts).with("> attempted to update with #{key}")
        lambda_function.expects(:puts).with("> error message: Error")

        lambda_function.update_code(object)
      end
    end
  end
end
