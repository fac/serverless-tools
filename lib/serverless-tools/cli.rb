require "thor"
require_relative "./comment"
require_relative "./deployer"
require_relative "./version"

module ServerlessTools
  class CLI < Thor
    desc "comment", "create Github Issue comment body"
    method_option :functions, :type => :string, :aliases => "-f", :default => "{}"
    def comment
      comment = Comment.new.build(options[:functions])
      puts "::set-output name=comment::#{comment}"
    end

    desc "deploy", "publishes and deploys the specified lambda functions"
    method_option :filename, :type => :string, :aliases => "-f"
    def deploy(action, function=nil)
      Deployer.deploy(action: action, function: function, filename: options[:filename])
    end

    desc "version", "prints the version of the library"
    def version
      puts VERSION
    end
  end
end
