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
            s3_key: key
          )
        ).returns(
          Aws::Lambda::Types::FunctionConfiguration.new(
            function_name: function_name,
            last_update_status: "InProgress"
          )
        )
    end

    describe "#update_code" do
      describe "when the waiter completes" do
        before do
          lambda_client.expects(:wait_until).with(
            :function_updated,
            { function_name: function_name },
            { max_attempts: 10, delay: 3 }
          ).returns(wait_response)
        end

        it "updates lambda code" do
          lambda_updater.expects(:puts).with("::set-output name=#{function_name}_status::Successful")
          response = lambda_updater.update(options)

          assert_equal(response, wait_response)
        end

        describe "when the waiter returns false" do
          let(:wait_response) { false }

          it "sets the status output to Failed" do
            lambda_updater.expects(:puts).with("::set-output name=#{function_name}_status::Failed")
            response = lambda_updater.update(options)

            assert_equal(response, wait_response)
          end
        end
      end
      describe "when an error is raised" do
        it "sets the output for the function with a failed status and returns false" do
          lambda_client.expects(:wait_until).with(
            :function_updated,
            { function_name: function_name },
            { max_attempts: 10, delay: 3 }
          ).raises(Aws::Lambda::Errors::ServiceError.new(mock, "Test Error"))

          lambda_updater.expects(:puts).with("::error:: An error occured when updating #{function_name} Test Error")
          lambda_updater.expects(:puts).with("::set-output name=#{function_name}_status::Failed")
          response = lambda_updater.update(options)

          assert_equal(response, false)
        end
      end
    end
  end
end
