# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem "aws-sdk-lambda"
gem "aws-sdk-s3"
gem "rake"

group :development do
  gem "rubocop", require: false
  gem "pry"
  gem "pry-byebug"
end

group :test do
  gem "test-unit"
  gem "minitest"
  gem "mocha"
end
