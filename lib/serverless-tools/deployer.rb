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

        log_github_output(deployer)
      rescue NoMethodError, ArgumentError => e
        puts "Given action not known! Got #{action}, expected one of [build, push, update, deploy]"
        log_github_error(deployer)
        raise e
      rescue StandardError => e
        log_github_error(deployer)
        raise e
      end
    end

    # When we're running inside a Github Action and its possible to log the output
    # we should. This opens up the possibility to report on the actions from other
    # steps in the job. However, we don't want to perform this if we're not in Github.
    def self.running_in_github?
      !ENV.fetch("GITHUB_ENV", "").empty?
    end

    # We don't use the system_command wrapper here as we don't care if this fails. i.e.
    # we don't want the logging of a successful deployment fail a deployment workflow.
    def self.log_github_output(deployer)
      return unless running_in_github?
      system("echo \"#{deployer.config.name}_status=Success\" >> \"$GITHUB_OUTPUT\"")
    end

    def self.log_github_error(deployer)
      return unless running_in_github?
      system("echo \"#{deployer.config.name}_status=Failed\" >> \"$GITHUB_OUTPUT\"")
    end
  end
end
