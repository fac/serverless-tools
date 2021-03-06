require "yaml"

require_relative "./deployer/function_deployer"
require_relative "./deployer/yaml_config_loader"

module ServerlessTools
  module Deployer
    def self.deploy(action:, options:, function: nil)
      raise "Expected to receive action but action was empty" if action.nil? || action.empty?

      config_loader = YamlConfigLoader.new(filename: options.filename)

      lambdas_to_deploy = function ? [function] : config_loader.functions

      deployers = lambdas_to_deploy.map do |function_name|
        FunctionDeployer.create_for_function(
          config: config_loader.lambda_config(function_name: function_name),
          options: options,
        )
      end

      run_action(action: action, deployers: deployers)
    end

    def self.run_action(action:, deployers:)
      deployers.each do |deployer|
        deployer.send(action)
      rescue NoMethodError, ArgumentError => e
        puts "Given action not known! Got #{action}, expected one of [build, push, update, deploy]"
        puts e.message
      end
    end
  end
end
