require "minitest/autorun"
require "mocha/minitest"

require "serverless-tools/deployer/python_builder"

module ServerlessTools::Deployer
  describe "PythonBuilder" do
    let(:config) { FunctionConfig.new(name: "function_one", handler_file: "handler_file") }
    let(:subject) { PythonBuilder.new(config: config) }

    def assert_file_exists?(exists = true)
      assert_equal(File.exist?(subject.local_filename), exists)
    end

    describe "#build" do
      it "creates a zip file for the Python code" do
        assert_file_exists?(false)

        subject.build

        assert_file_exists?(true)

        File.delete(subject.local_filename)

        # Delete package directory created by Python deployer build method
        File.delete("requirements.txt")
        FileUtils.remove_dir("./package",true)
      end

      describe "#local_filename" do
        it "generates the correct name for the local zip archive" do
          assert_equal("function_one.zip", subject.local_filename)
        end
      end
    end
  end
end
