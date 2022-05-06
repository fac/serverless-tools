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
        Deployer.deploy(action: "build", function: function)
      end

      describe "when specifying a force" do
        let(:options) { Deployer::Options.new(force: true, filename: filename) }

        before do
          Deployer::Options.stubs(:new)
            .with(force: true, filename: filename)
            .returns(options)
        end

        it "creates the correct options" do
          Deployer.deploy(action: "build", function: function, options: { force: true, filename: filename })
        end
      end

      describe "when specifying a different config file" do
        let(:filename) { "dev.functions.yml" }
        let(:options) { Deployer::Options.new(filename: filename) }

        before do
          Deployer::Options.stubs(:new)
            .with(filename: filename)
            .returns(options)
        end

        it "loads the correct file" do
          Deployer.deploy(action: "build", function: function, options: { filename: filename })
        end
      end
    end
  end
end
