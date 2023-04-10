require "minitest/autorun"
require "mocha/minitest"

require "serverless-tools/deployer/ruby_builder"

module ServerlessTools::Deployer
  describe "RubyBuilder" do
    let(:config) { FunctionConfig.new(name: "function_one", handler_file: "handler_file") }
    let(:subject) { RubyBuilder.new(config: config) }

    describe "#build" do
      it "creates a zip file for the ruby code" do
        subject.expects(:system_call).with("bundle")
        subject.expects(:system_call).with("zip -r \"function_one.zip\" handler_file lib vendor/")

        subject.build

      end

      describe "#local_filename" do
        it "generates the correct name for the local zip archive" do
          assert_equal("function_one.zip", subject.local_filename)
        end
      end
    end
  end
end
