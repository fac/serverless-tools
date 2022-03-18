require "minitest/autorun"
require "mocha/minitest"

require "serverless-tools/deployer"

module ServerlessTools
  describe "Deployer" do
    let(:deployer) { mock() }
    let(:config) { mock() }

    let(:function) { "example_function_one_v1" }
    let(:filename) { "functions.yml" }


    describe "#deployer" do
      before do
        Deployer::YamlConfigLoader.stubs(:new).with(filename: filename).returns(config)
        Deployer::FunctionDeployer.stubs(:create_for_function).returns(deployer)

        config.expects(:lambda_config).with(function_name: function)
        deployer.expects(:build)
      end

      it "sends the action to the created deployer" do
        Deployer.deploy(action: "build", function: function)
      end

      describe "when specifying a different config file" do
        let(:filename) { "dev.functions.yml" }

        it "loads the correct file" do
          Deployer.deploy(action: "build", function: function, filename: filename)
        end
      end
    end
  end
end
