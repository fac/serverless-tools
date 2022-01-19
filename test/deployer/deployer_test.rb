require "minitest/autorun"
require "mocha/minitest"

require "aws-sdk-lambda"
require "aws-sdk-s3"

require "serverless-tools/deployer/deployer"
require "serverless-tools/deployer/function_config"

describe "Deployer" do
  let(:s3_object_does_not_exist) do
    Aws::S3::Client.new(stub_responses: {
                          head_object: { status_code: 404, headers: {}, body: "" },
                          put_object: { status_code: 200, headers: {}, body: "" }
                        })
  end
  let(:s3_object_does_exist) do
    Aws::S3::Client.new(stub_responses: {
                          head_object: { status_code: 200, headers: {}, body: "" }
                        })
  end

  let(:lambda_client) { Aws::Lambda::Client.new(stub_responses: true) }

  let(:git) { mock() }

  let(:config) do
    ServerlessTools::Deployer::FunctionConfig.new(
      name: "example_function_one_v1",
      bucket: "freeagent-lambda-example-scripts",
      repo: "serverless-tools",
      s3_archive_name: "function.zip"
    )
  end

  before do
    git.stubs(:sha).returns("1234567890")
  end

  describe "#push" do
    it "uploads file to S3 object when object doesn't exist" do

      uploader = ServerlessTools::Deployer::Deployer.new(
        config,
        s3_client: s3_object_does_not_exist,
        lambda_client: lambda_client,
        git: git,
      )
      uploader.build
      uploader.push
      File.delete(config.local_filename) if File.exist?(config.local_filename)

      # now check the API requests, unfortunately it seems as though the
      # resources don't use the client methods (e.g. client.head_object)
      # but directly make API requests, however the client does record the
      # requests made.

      # under the hood object.exists? uses head_object - check it was called
      #  with correct params. While this is not strictly required (it tests an
      # internal detail of the class) it is potentially instructive so is left
      # in this first test, but not the subsequent ones
      head_object_requests = s3_object_does_not_exist.api_requests.select { |x|
 x[:operation_name] == :head_object }
      assert_equal(1, head_object_requests.length)
      assert_equal(
        "freeagent-lambda-example-scripts",
        head_object_requests.first[:params][:bucket]
      )
      assert_equal(
        "serverless-tools/deployments/1234567890/example_function_one_v1/function.zip",
        head_object_requests.first[:params][:key]
      )

      # eventually the push method will call object.upload, this will make a
      # put_object call
      put_object_requests = s3_object_does_not_exist.api_requests.select { |x| x[:operation_name] == :put_object }
      assert_equal(1, put_object_requests.length)
      assert_equal(
        "freeagent-lambda-example-scripts",
        put_object_requests.first[:params][:bucket]
      )
      assert_equal(
        "serverless-tools/deployments/1234567890/example_function_one_v1/function.zip",
        put_object_requests.first[:params][:key]
      )
    end

    it "does not upload file to S3 object when object exists" do
      uploader = ServerlessTools::Deployer::Deployer.new(
        config,
        s3_client: s3_object_does_exist,
        lambda_client: lambda_client,
        git: git
      )
      uploader.push

      # see comments above for checking the requests
      # eventually the push method will call object.upload, this will make a
      # put_object call, in this case we want no calls to be made
      put_object_requests = s3_object_does_exist.api_requests.select { |x| x[:operation_name] == :put_object }
      assert_equal(0, put_object_requests.length)
    end
  end

  describe "#update" do
    it "updates lambda code if code object exists" do
      lambda_client
        .expects(:update_function_code)
        .with(
          has_entries(
            s3_bucket: "freeagent-lambda-example-scripts",
            s3_key: "serverless-tools/deployments/1234567890/example_function_one_v1/function.zip"
          )
        ).returns({ function_name: "test-function", last_update_status: "Successful" })

      uploader = ServerlessTools::Deployer::Deployer.new(
        config,
        s3_client: s3_object_does_exist,
        lambda_client: lambda_client,
        git: git,
      )
      uploader.update
    end

    it "does not update lambda code if code object does not exist" do
      lambda_client.expects(:update_function_code).never

      uploader = ServerlessTools::Deployer::Deployer.new(
        config,
        s3_client: s3_object_does_not_exist,
        lambda_client: lambda_client,
        git: git
      )
      uploader.update
    end
  end
end
