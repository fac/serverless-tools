require "minitest/autorun"
require "mocha/minitest"

require "serverless-tools/deployer"

module ServerlessTools
  describe "Deployer" do
    let(:deployer) { mock() }
    let(:config) { mock() }
    let(:lambda_config) { mock() }

    let(:options) { Deployer::Options.new(filename: "functions.yml", force: false) }

    let(:function) { "example_function_one_v1" }
    let(:filename) { "functions.yml" }


    describe "#deployer" do
      before do
        Deployer::YamlConfigLoader.stubs(:new).with(filename: filename).returns(config)
        Deployer::FunctionDeployer.stubs(:create_for_function).with(config: lambda_config,
          options: options).returns(deployer)

        Deployer.stubs(:system)
        config.stubs(:lambda_config).with(function_name: function).returns(lambda_config)

        lambda_config.stubs(:name).returns(function)
        deployer.stubs(:config).returns(lambda_config)
        deployer.stubs(:build)

        ENV.stubs(:fetch).with("GITHUB_ENV", "").returns("ENV VAR SET BY GITHUB")
      end

      it "sends the action to the created deployer" do
        Deployer.deploy(action: "build", function: function, options: options)
      end

      describe "$GITHUB_OUTPUT" do
        describe "when the function is updated successfully" do
          it "outputs the correct status" do
            Deployer.expects(:system).with("echo \"#{function}_status=Success\" >> \"$GITHUB_OUTPUT\"")
            Deployer.deploy(action: "build", function: function, options: options)
          end
        end

        describe "when the function errors" do
          before do
            deployer.stubs(:update).raises(StandardError)
          end

          it "captures the error output to send to Github" do
            Deployer.expects(:system).with("echo \"#{function}_status=Failed\" >> \"$GITHUB_OUTPUT\"")
            assert_raises StandardError do
              Deployer.deploy(action: "update", function: function, options: options)
            end
          end
        end

        describe "when the action does not exist" do
          before do
            deployer.stubs(:no_method).raises(NoMethodError)
          end
          it "captures the error output to send to Github" do
            Deployer.expects(:system).with("echo \"#{function}_status=Failed\" >> \"$GITHUB_OUTPUT\"")
            Deployer.expects(:puts).with(
              "Given action not known! Got no_method, expected one of [build, push, update, deploy]"
            )

            assert_raises NoMethodError do
              Deployer.deploy(action: "no_method", function: function, options: options)
            end
          end
        end
      end
    end
  end
end
