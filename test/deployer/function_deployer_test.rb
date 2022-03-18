require "minitest/autorun"
require "mocha/minitest"

require "serverless-tools/deployer/function_deployer"
require "serverless-tools/deployer/function_config"
require "serverless-tools/deployer/errors"

module ServerlessTools::Deployer
  describe "FunctionDeployer" do
    let(:pusher) { mock() }
    let(:builder) { mock() }
    let(:updater) { mock() }
    let(:bucket) { "freeagent-lambda-example-scripts" }
    let(:key) { "function.zip" }

    let(:config) do
      FunctionConfig.new(
        name: "example_function_one_v1",
        bucket: bucket,
        repo: "serverless-tools",
        s3_archive_name: key,
        handler_file: "handler.rb",
      )
    end

    describe "#deploy" do
      it "calls each member of the deployer class to deploy the function" do
        deployer = FunctionDeployer.new(config, pusher: pusher, updater: updater, builder: builder)

        builder.expects(:build)
        builder.expects(:output).returns({ local_filename: key })

        pusher.expects(:push).with(local_filename: key)
        pusher.expects(:output).returns({ s3_key: key, s3_bucket: bucket })

        updater.expects(:update).with(s3_key: key, s3_bucket: bucket)

        deployer.deploy
      end
    end

    describe "#build" do
      it "calls the build method of the builder with the config" do
        deployer = FunctionDeployer.new(config, pusher: pusher, updater: updater, builder: builder)
        builder.expects(:build)
        deployer.build
      end
    end

    describe "#push" do
      it "calls the push method of the pusher with the config" do
        deployer = FunctionDeployer.new(config, pusher: pusher, updater: updater, builder: builder)

        builder.expects(:output).returns({ local_filename: key })
        pusher.expects(:push).with(local_filename: key)

        deployer.push
      end
    end

    describe "#update" do
      it "calls the update method of the updater with the config" do
        deployer = FunctionDeployer.new(config, pusher: pusher, updater: updater, builder: builder)

        pusher.expects(:output).returns({ s3_key: key, s3_bucket: bucket })

        updater.expects(:update).with(s3_key: key, s3_bucket: bucket)

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

      it "returns a deployer with a pusher, updater, and builder" do
        result = FunctionDeployer.create_for_function(config: config)

        assert_equal(result.class.name, "ServerlessTools::Deployer::FunctionDeployer")
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
            FunctionDeployer.create_for_function(config: config)
          end
        end
      end
    end
  end
end
