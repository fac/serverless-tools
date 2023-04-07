require "minitest/autorun"
require "mocha/minitest"
require "fileutils"
require "serverless-tools/deployer/python_builder"

module ServerlessTools::Deployer
  describe "PythonBuilder" do
    let(:config) { FunctionConfig.new(name: "function_one", handler_file: "handler_file") }
    let(:subject) { PythonBuilder.new(config: config) }

    describe "#build" do
      it "creates a zip file for the Python code" do

        subject.expects(:system_call).with("poetry build")
        subject.expects(:system_call).with("python3 -m pip install -t lambda-package dist/*.whl")
        subject.expects(:system_call).with("zip -jr \"function_one.zip\" handler_file")
        subject.expects(:system_call).with("cd lambda-package && zip -r \"../function_one.zip\" ./*")

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
