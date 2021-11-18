require "yaml"

require_relative "./deployer/aws_lambda_config"
require_relative "./deployer/deployer"

module ServerlessTools
  module Deployer
    CONFIG_FILE = ENV["GITHUB_WORKSPACE"] ? "#{ENV["GITHUB_WORKSPACE"]}/functions.yml" : "functions.yml"

    def self.deploy(action:, function: nil)
      raise "Expected to receive action but action was empty" if action.nil? || action.empty?

      lambdas_to_deploy = if function
                            [function]
                          else
                            YAML.load_file(CONFIG_FILE).keys
      end

      configs = lambdas_to_deploy.map { |l| AwsLambdaConfig.new(filename: CONFIG_FILE, function_name: l) }
      deployers = configs.map { |c| Deployer.new(c) }

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
