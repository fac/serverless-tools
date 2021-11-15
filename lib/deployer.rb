require 'yaml'

require_relative './deployer/aws_lambda_config'
require_relative './deployer/deployer'

module Deployer
  CONFIG_FILE = 'functions.yml'

  def self.deploy(action:, function: nil)
    lambdas_to_deploy = if function
                          [function]
                        else
                          YAML.load_file(CONFIG_FILE).keys
                        end

    configs = lambdas_to_deploy.map { |l| AwsLambdaConfig.new(filename: CONFIG_FILE, function_name: l) }
    deployers = configs.map { |c| Deployer.new(c) }

    case action
    when 'build'
      deployers.each { |d| d.build }
    when 'push'
      deployers.each { |d| d.push }
    when 'update'
      deployers.each { |d| d.update }
    when 'deploy'
      deployers.each { |d| d.deploy }
    else
      puts "Given action not known! Got #{action}, expected one of [build, push, update, deploy]"
    end
  end
end

Deployer.deploy(action: ARGV[0], function: ARGV[1])
