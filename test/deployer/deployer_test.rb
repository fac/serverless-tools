require "minitest/autorun"
require "mocha/minitest"

require "serverless-tools/deployer/deployer"
require "serverless-tools/deployer/function_config"
require "serverless-tools/deployer/errors"

module ServerlessTools::Deployer
  describe "Deployer" do
    let(:pusher) { mock() }
    let(:builder) { mock() }
    let(:updater) { mock() }

    let(:config) do
      FunctionConfig.new(
        name: "example_function_one_v1",
        bucket: "freeagent-lambda-example-scripts",
        repo: "serverless-tools",
        s3_archive_name: "function.zip",
        handler_file: "handler.rb",
      )
    end

    describe "#deploy" do
      it "calls each member of the deployer class to deploy the function" do
        deployer = Deployer.new(config, pusher: pusher, updater: updater, builder: builder)

        builder.expects(:build).with(config: config)
        pusher.expects(:push).with(config: config)
        updater.expects(:update).with(config: config)

        deployer.deploy
      end
    end

    describe "#build" do
      it "calls the build method of the builder with the config" do
        deployer = Deployer.new(config, pusher: pusher, updater: updater, builder: builder)
        builder.expects(:build).with(config: config)
        deployer.build
      end
    end

    describe "#push" do
      it "calls the push method of the pusher with the config" do
        deployer = Deployer.new(config, pusher: pusher, updater: updater, builder: builder)
        pusher.expects(:push).with(config: config)
        deployer.push
      end
    end

    describe "#update" do
      it "calls the update method of the updater with the config" do
        deployer = Deployer.new(config, pusher: pusher, updater: updater, builder: builder)
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
        assert_equal(result.builder.class.name, "ServerlessTools::Deployer::RubyBuilder")
      end

      describe "when the config can't be infered" do
        let(:config) do
          FunctionConfig.new()
        end

        it "raises a RuntimeNotSupported error" do
          assert_raises(RuntimeNotSupported) do
            Deployer.create_for_function(config: config)
          end
        end
      end
    end
  end
end
