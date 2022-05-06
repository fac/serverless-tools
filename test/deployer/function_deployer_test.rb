require "minitest/autorun"
require "mocha/minitest"

require "serverless-tools/deployer/function_deployer"
require "serverless-tools/deployer/function_config"
require "serverless-tools/deployer/options"
require "serverless-tools/deployer/errors"

module ServerlessTools::Deployer
  describe "FunctionDeployer" do
    let(:pusher) { mock("pusher") }
    let(:builder) { mock("builder") }
    let(:updater) { mock("updater") }
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

    let(:options) { Options.new }

    subject do
      FunctionDeployer.new(pusher: pusher, updater: updater, builder: builder, options: options)
    end

    describe "#deploy" do
      it "calls each member of the deployer class to deploy the function" do
        builder.expects(:build)
        builder.expects(:output).returns({ local_filename: key })

        pusher.expects(:output).returns({ s3_key: key, s3_bucket: bucket })
        pusher.expects(:output).returns({})
        pusher.expects(:push).with(local_filename: key)

        updater.expects(:update).with(s3_key: key, s3_bucket: bucket)

        subject.deploy
      end
    end

    describe "#build" do
      it "calls the build method of the builder with the config" do
        builder.expects(:build)
        subject.build
      end
    end

    describe "#push" do
      it "calls the push method of the pusher with the config" do
        builder.expects(:output).returns({ local_filename: key })
        pusher.expects(:output).returns({})

        pusher.expects(:push).with(local_filename: key)

        subject.push
      end

      describe "when the pusher has already pushed the asset" do
        it "does not call push" do
          pusher.expects(:output).returns({ s3_bucket: "test", s3_key: "test" })

          builder.expects(:output).times(0)
          pusher.expects(:push).times(0)

          subject.push
        end
      end

      describe "when the force option is present" do
        let(:options) { Options.new(force: true) }
        it "will call push" do
          builder.expects(:output).returns({ local_filename: key })
          pusher.expects(:push).with(local_filename: key)

          subject.push
        end
      end
    end

    describe "#update" do
      it "calls the update method of the updater with the config" do
        pusher.expects(:output).returns({ s3_key: key, s3_bucket: bucket })

        updater.expects(:update).with(s3_key: key, s3_bucket: bucket)

        subject.update
      end
    end

    describe "#create_for_function" do
      describe "for Ruby runtime" do
        let(:ruby_config) { FunctionConfig.new(handler_file: "handler.rb") }

        before do
          Aws::S3::Client.stubs(:new)
          Aws::Lambda::Client.stubs(:new)
        end

        it "returns a deployer with a pusher, updater, and builder" do
          result = FunctionDeployer.create_for_function(config: ruby_config)

          assert_equal(result.class.name, "ServerlessTools::Deployer::FunctionDeployer")
          assert_equal(result.pusher.class.name, "ServerlessTools::Deployer::S3Pusher")
          assert_equal(result.updater.class.name, "ServerlessTools::Deployer::LambdaUpdater")
          assert_equal(result.builder.class.name, "ServerlessTools::Deployer::RubyBuilder")
        end
      end

      describe "for Docker runtime" do
        let(:docker_config) { FunctionConfig.new(dockerfile: "Dockerfile") }

        before do
          Aws::ECR::Client.stubs(:new)
          Aws::Lambda::Client.stubs(:new)
        end

        it "returns a deployer with a pusher, updater, and builder" do
          result = FunctionDeployer.create_for_function(config: docker_config)

          assert_equal(result.class.name, "ServerlessTools::Deployer::FunctionDeployer")
          assert_equal(result.pusher.class.name, "ServerlessTools::Deployer::EcrPusher")
          assert_equal(result.updater.class.name, "ServerlessTools::Deployer::LambdaUpdater")
          assert_equal(result.builder.class.name, "ServerlessTools::Deployer::DockerBuilder")
        end
      end

      describe "when the config can't be inferred" do
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
