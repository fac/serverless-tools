require "yaml"

require_relative "./deployer/deployer"
require_relative "./deployer/yaml_config_loader"

module ServerlessTools
  module Deployer
    CONFIG_FILE = ENV["GITHUB_WORKSPACE"] ? "#{ENV["GITHUB_WORKSPACE"]}/functions.yml" : "functions.yml"

    def self.deploy(action:, function: nil)
      raise "Expected to receive action but action was empty" if action.nil? || action.empty?

      config_loader = YamlConfigLoader.new(filename: CONFIG_FILE)

      lambdas_to_deploy = function ? [function] : config_loader.functions

      deployers = lambdas_to_deploy.map do |function_name|
        Deployer.new(
          config_loader.lambda_config(function_name: function_name)
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
