#!/usr/bin/env ruby
require "json"

# Script that is intended to be used to publish a comment to github
# where the body is the output of another program. e.g., to convey
# a deployment status.

function_json = ARGV[0]

lines = ["Functions updated for sha: #{ENV["GITHUB_SHA"]} %0A"]
lines << JSON.parse(function_json).map do |function, status|
 "> **#{function}**: #{status} %0A"
end

puts "::set-output name=comment::#{lines.join}"
