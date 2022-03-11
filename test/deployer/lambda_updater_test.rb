require "minitest/autorun"
require "mocha/minitest"
require "aws-sdk-lambda"

require "serverless-tools/deployer/lambda_updater"
require "serverless-tools/deployer/function_config"

module ServerlessTools::Deployer
  describe "AwsLambdaFunction" do
    let(:lambda_client) { Aws::Lambda::Client.new(stub_responses: true) }

    let(:function_name) { "example_function_one_v1" }
    let(:key) { "serverless-tools/deployments/1234567890/#{function_name}/function.zip" }
    let(:bucket) { "freeagent-lambda-example-scripts" }

    let(:config) do
      FunctionConfig.new(
        name: "example_function_one_v1",
        bucket: bucket,
        repo: "serverless-tools",
        s3_archive_name: "function.zip"
      )
    end

    let(:pusher) { mock }

    describe "#update_code" do
      it "updates lambda code" do
        lambda_client
          .expects(:update_function_code)
          .with(
            has_entries(
              s3_bucket: bucket,
              s3_key: key
            )
          ).returns({ function_name: function_name, last_update_status: "Successful" })

        lambda_function = LambdaUpdater.new(client: lambda_client, pusher: pusher)

        push_response = { s3_key: key, s3_bucket: bucket }
        pusher.expects(:push).with(config: config).returns(push_response)

        lambda_function.expects(:puts).with("::set-output name=#{function_name}_status::Successful")

        lambda_function.update(config: config)
      end
    end
  end
end
