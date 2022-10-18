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
    let(:function_name) { "example_function_one_v1" }

    let(:config) do
      FunctionConfig.new(
        name: function_name,
        bucket: bucket,
        repo: "serverless-tools",
        s3_archive_name: key,
        handler_file: "handler.rb",
      )
    end

    let(:options) { Options.new }
    let(:in_github) { "" }

    subject do
      FunctionDeployer.new(
        pusher: pusher,
        updater: updater,
        builder: builder,
        options: options,
        config: config,
        in_github: in_github,
      )
    end

    before do
      subject.stubs(:puts)
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

        subject.expects(:puts).with("    📦 Assets built")

        subject.build
      end
    end

    describe "#push" do
      it "calls the push method of the pusher with the config" do
        builder.expects(:output).returns({ local_filename: key })
        pusher.expects(:output).returns({})

        subject.expects(:puts).with("    ⬆️  Assets pushed")

        pusher.expects(:push).with(local_filename: key)

        subject.push
      end

      describe "when the pusher has already pushed the asset" do
        before do
          pusher.expects(:output).returns({ s3_bucket: "test", s3_key: "test" })
        end

        it "does not call push" do
          builder.expects(:output).times(0)
          pusher.expects(:push).times(0)

          subject.push
        end

        it "logs to let the user know the assets have not been pushed" do
          subject.expects(:puts).with("    🛑 Assets have not been updated")

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
      let(:s3_config) {{ s3_key: key, s3_bucket: bucket }}
      let(:s3_update_output) {{ **s3_config, function_name: function_name }}

      it "calls the update method of the updater with the config" do
        pusher.expects(:output).returns(s3_config)

        updater.expects(:update).with(s3_key: key, s3_bucket: bucket).returns(s3_update_output)

        subject.expects(:puts).with("    ✅ Sucessfully updated")

        subject.update
      end

      describe "and the deployer is running on Github" do
        let(:in_github) { "GITHUB_ENV" }
        it "logs an output for github" do
          pusher.expects(:output).returns(s3_config)

          updater.expects(:update).with(s3_key: key, s3_bucket: bucket).returns(s3_update_output)

          subject.expects(:puts).with("    ✅ Sucessfully updated")
          subject.expects(:system).with("echo \"#{function_name}_status=Success\" >> \"$GITHUB_OUTPUT\"")

          subject.update
        end
      end

      describe "when the update fails" do
        it "logs an appropriate failed message" do
          pusher.expects(:output).returns({ s3_key: key, s3_bucket: bucket })

          updater.expects(:update).with(s3_key: key,
s3_bucket: bucket).raises(Aws::Lambda::Errors::ServiceError.new(mock, "Test Error"))

          subject.expects(:puts).with("    ❌ Failed to update")

          subject.update
        end

        describe("and the deployer is running on Github") do
          let(:in_github) { "GITHUB_ENV" }
          it "logs an output error for github" do
            pusher.expects(:output).returns({ s3_key: key, s3_bucket: bucket })

            updater.expects(:update).with(s3_key: key,
s3_bucket: bucket).raises(Aws::Lambda::Errors::ServiceError.new(mock, "Test Error"))

            subject.expects(:puts).with("    ❌ Failed to update")
            subject.expects(:system).with("echo \"#{function_name}_status=Failed\" >> \"$GITHUB_OUTPUT\"")

            subject.update
          end
        end
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
          result = FunctionDeployer.create_for_function(config: ruby_config, options: options)

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
          result = FunctionDeployer.create_for_function(config: docker_config, options: options)

          assert_equal(result.class.name, "ServerlessTools::Deployer::FunctionDeployer")
          assert_equal(result.pusher.class.name, "ServerlessTools::Deployer::EcrPusher")
          assert_equal(result.updater.class.name, "ServerlessTools::Deployer::LambdaUpdater")
          assert_equal(result.builder.class.name, "ServerlessTools::Deployer::DockerBuilder")
        end
      end

      describe "for Pythonn runtime" do
        let(:python_config) { FunctionConfig.new(handler_file: "handler.py") }

        before do
          Aws::S3::Client.stubs(:new)
          Aws::Lambda::Client.stubs(:new)
        end

        it "returns a deployer with a pusher, updater, and builder" do
          result = FunctionDeployer.create_for_function(config: python_config, options: options)

          assert_equal(result.class.name, "ServerlessTools::Deployer::FunctionDeployer")
          assert_equal(result.pusher.class.name, "ServerlessTools::Deployer::S3Pusher")
          assert_equal(result.updater.class.name, "ServerlessTools::Deployer::LambdaUpdater")
          assert_equal(result.builder.class.name, "ServerlessTools::Deployer::PythonBuilder")
        end
      end

      describe "when the config can't be inferred" do
        let(:config) do
          FunctionConfig.new()
        end

        it "raises a RuntimeNotSupported error" do
          assert_raises(RuntimeNotSupported) do
            FunctionDeployer.create_for_function(config: config, options: options)
          end
        end
      end
    end
  end
end
