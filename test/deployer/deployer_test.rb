require "minitest/autorun"
require "mocha/minitest"

require "serverless-tools/deployer/deployer"
require "serverless-tools/deployer/function_config"

module ServerlessTools::Deployer
  describe "Deployer" do
    let(:pusher) { mock() }
    let(:updater) { mock() }

    let(:config) do
      FunctionConfig.new(
        name: "example_function_one_v1",
        bucket: "freeagent-lambda-example-scripts",
        repo: "serverless-tools",
        s3_archive_name: "function.zip"
      )
    end

    describe "#push" do
      it "calls the upload method of the uploader with the config" do
        deployer = Deployer.new(config, pusher: pusher, updater: updater)
        pusher.expects(:push).with(config: config)
        deployer.push
      end
    end

    describe "#update" do
      it "calls the update method of the updater with the config" do
        deployer = Deployer.new(config, pusher: pusher, updater: updater)
        updater.expects(:update).with(config: config)
        deployer.update
      end
    end

    describe "#create_for_function" do
      let(:s3) { Aws::S3::Client.new(stub_responses: true) }
      let(:lambda_client) { Aws::Lambda::Client.new(stub_responses: true) }

      before do
        Aws::S3::Client.stubs(:new).returns(s3)
        Aws::Lambda::Client.stubs(:new).returns(lambda_client)
      end

      it "returns a deployer with an pusher and updater" do
        result = Deployer.create_for_function(config: config)

        assert_equal(result.class.name, "ServerlessTools::Deployer::Deployer")
        assert_equal(result.pusher.class.name, "ServerlessTools::Deployer::S3Pusher")
        assert_equal(result.updater.class.name, "ServerlessTools::Deployer::LambdaUpdater")
      end
    end
  end
end
