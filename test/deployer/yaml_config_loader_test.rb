require "minitest/autorun"

require "serverless-tools/deployer/yaml_config_loader"
require "serverless-tools/deployer/errors"

module ServerlessTools
  module Deployer
    describe "YamlConfigLoader" do
      let(:filename) { "test/fixtures/functions.yml" }
      let(:loader) { YamlConfigLoader.new(filename: filename) }

      describe "#initialilze" do
        it "loads the yaml file" do
          assert_instance_of(YamlConfigLoader, loader)

          refute_nil(loader.data)
          refute_nil(loader.filename)
        end

        describe "when the file can't be found" do
          it "raises a FileNotFound error" do
            err = assert_raises(ConfigFileNotFound) do
              YamlConfigLoader.new(filename: "no_file_here")
            end

            assert_equal(err.message, "Could not find config file 'no_file_here'")
          end
        end

      end

      describe "#functions" do
        it "returns an Array of functions specified in the file" do
          assert_equal(["example_function_one_v1", "example_function_two_v1"], loader.functions)
        end
      end

      describe "#lambda_config" do
        it "returns an object for a given function" do
          config = loader.lambda_config(function_name: "example_function_one_v1")

          assert_equal("example_function_one_v1", config.name)
          assert_equal("serverless-tools", config.repo)
          assert_equal("function.zip", config.s3_archive_name)
          assert_equal("handler_one.rb", config.handler_file)
          assert_equal("freeagent-lambda-example-scripts", config.bucket)
        end

        describe "when the function does not exist" do
          it "raises a FunctionConfigNotFound error" do
            err = assert_raises(FunctionConfigNotFound) do
              loader.lambda_config(function_name: "missing_function")
            end

            assert_equal(
              err.message,
              "Could not find the config for function 'missing_function' in 'test/fixtures/functions.yml'",
            )
          end
        end
      end
    end
  end
end
