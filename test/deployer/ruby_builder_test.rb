require "minitest/autorun"
require "mocha/minitest"

require "serverless-tools/deployer/ruby_builder"

module ServerlessTools::Deployer
  describe "RubyBuilder" do
    let(:subject) { RubyBuilder.new }
    let(:config) { FunctionConfig.new(name: "function_one", handler_file: "handler_file") }

    describe "#build" do
      it "creates a zip file for the ruby code" do
        assert_equal(File.exist?(config.local_filename), false)

        subject.build(config: config)

        assert_equal(File.exist?(config.local_filename), true)

        File.delete(config.local_filename)
      end
    end
  end
end
