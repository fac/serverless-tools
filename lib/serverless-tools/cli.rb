require "thor"
require_relative "./comment"
require_relative "./deployer"
require_relative "./notifier"
require_relative "./deployer/options"
require_relative "./version"

module ServerlessTools
  class CLI < Thor
    desc "comment", "create Github Issue comment body"
    method_option :functions, :type => :string, :aliases => "-f", :default => "{}"
    def comment
      system("echo \"comment<<EOF\" >> $GITHUB_OUTPUT")
      Comment.new.build(options[:functions]) do |line|
        system("echo \"#{line}\" >> $GITHUB_OUTPUT")
      end
      system("echo \"EOF\" >> $GITHUB_OUTPUT")
    end

    desc "deploy", "publishes and deploys the specified lambda functions"
    method_option :filename, :type => :string, :aliases => "-f", :default => "functions.yml"
    method_option :force, :type => :boolean, :aliases => "-x", :default => false
    def deploy(action, function=nil)
      Deployer.deploy(
        action: action,
        function: function,
        options: Deployer::Options.new(**options)
      )
    end

    desc "notify STATUS RUN_ID", "reports deployment status to Slack"
    method_option :repo, :type => :string, :aliases => "-r", :required => true
    method_option :channel, :type => :string, :aliases => "-c", :required => true
    def notify(status, run_id)
      Notifier.notify(
        status: status,
        run_id: run_id,
        repo_name: options[:repo],
        channel: options[:channel],
      )
    end

    desc "version", "prints the version of the library"
    def version
      puts VERSION
    end
  end
end
