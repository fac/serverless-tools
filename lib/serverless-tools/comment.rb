require "json"
require_relative "git"

module ServerlessTools
  class Comment
    def initialize(git: Git.new)
      @git = git
    end

    def build(function_json)
      lines = ["Functions updated for sha: #{@git.sha} %0A"]
      lines << JSON.parse(function_json).map do |function, status|
      "> **#{function}**: #{status} %0A"
      end
      lines.join
    end
  end
end
