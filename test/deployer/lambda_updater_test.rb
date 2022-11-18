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

    let(:wait_response) { true }
    let(:options) {{ s3_key: key, s3_bucket: bucket }}

    let(:config) do
      FunctionConfig.new(
        name: "example_function_one_v1",
        bucket: bucket,
        repo: "serverless-tools",
        s3_archive_name: "function.zip"
      )
    end

    let(:lambda_updater) { LambdaUpdater.new(client: lambda_client, config: config) }

    before do
      lambda_client
        .expects(:update_function_code)
        .with(
          has_entries(
            s3_bucket: bucket,
            s3_key: key,
            publish: true,
          )
        ).returns(
          Aws::Lambda::Types::FunctionConfiguration.new(
            function_name: function_name,
            last_update_status: "InProgress"
          )
        )

      lambda_client.expects(:wait_until).with(
        :function_updated,
        { function_name: function_name },
        { max_attempts: 10, delay: 3 }
      ).returns(wait_response)
    end

    describe "#update_code" do
      it "updates lambda code" do
        response = lambda_updater.update(options.freeze)

        assert_equal(options, { s3_key: key, s3_bucket: bucket })
        assert_equal(response, { **options, function_name: function_name, publish: true } )
      end
    end
  end
end
