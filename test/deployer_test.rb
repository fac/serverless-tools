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

        config.expects(:lambda_config).with(function_name: function).returns(lambda_config)
        deployer.expects(:build)
      end

      it "sends the action to the created deployer" do
        Deployer.deploy(action: "build", function: function, options: options)
      end
    end
  end
end
