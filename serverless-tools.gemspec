lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "serverless-tools/version"

Gem::Specification.new do |spec|
  spec.name          = "serverless-tools"
  spec.version       = ServerlessTools::VERSION
  spec.authors       = ["FreeAgent"]

  spec.summary       = "Serverless Tools"
  spec.description   = "A collection of tools used to ease the use of serverless projects"
  spec.homepage      = "https://www.freeagent.com"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = 'https://rubygems.pkg.github.com/fac'

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/fac/serverless-tools"
    spec.metadata["changelog_uri"] = "https://github.com/fac/serverless-tools/releases"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["lib/**/*"] + %w(Gemfile LICENSE README.md Rakefile serverless-tools.gemspec)
  spec.bindir        = "bin"
  spec.executables   = ["serverless-tools"]
  spec.require_paths = ["lib"]

  spec.requirements = ["zip", "git", "docker", "python3", "poetry", "bundle"]

  spec.post_install_message = "Serverless tools, and beyond!"

  spec.add_development_dependency "bundler", "~> 2.2.31"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rubocop"

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "mocha"

  spec.add_runtime_dependency "aws-sdk-lambda"
  spec.add_runtime_dependency "aws-sdk-s3"
  spec.add_runtime_dependency "aws-sdk-ecr"
  spec.add_runtime_dependency "thor"
end
