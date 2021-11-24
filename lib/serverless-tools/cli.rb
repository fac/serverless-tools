require "thor"
require_relative "./comment"
require_relative "./deployer"

module ServerlessTools
  class CLI < Thor
    desc "comment", "create Github Issue comment body"
    method_option :functions, :type => :string, :aliases => "-f", :default => "{}"
    def comment
      comment = Comment.new.build(options[:functions])
      puts "::set-output name=comment::#{comment}"
    end

    desc "deploy", "publishes and deploys the specified lambda functions"
    def deploy(action, function=nil)
      Deployer.deploy(action: action, function: function)
    end
  end
end
