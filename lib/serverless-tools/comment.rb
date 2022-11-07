require "json"
require_relative "git"

module ServerlessTools
  class Comment
    def initialize(git: Git.new)
      @git = git
    end

    def build(function_json)
      lines = ["Functions updated for sha: #{@git.sha}"]
      JSON.parse(function_json).each do |function, status|
        lines << "> **#{function}**: #{status}"
      end

      if block_given?
        lines.map { |line| yield line }
      end

      lines.join("\n")
    end
  end
end
