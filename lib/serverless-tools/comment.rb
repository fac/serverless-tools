require "json"

module ServerlessTools
  class Comment
    def self.build(function_json)
      lines = ["Functions updated for sha: #{ENV["GITHUB_SHA"]} %0A"]
      lines << JSON.parse(function_json).map do |function, status|
      "> **#{function}**: #{status} %0A"
      end
      lines.join
    end
  end
end
