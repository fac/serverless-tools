require "minitest/autorun"
require "mocha/minitest"
require "aws-sdk-s3"

require "serverless-tools/deployer/s3_pusher"
require "serverless-tools/deployer/function_config"

module ServerlessTools::Deployer
  describe "S3Pusher" do
    let(:s3) { Aws::S3::Client.new(stub_responses: true) }
    let(:git) { mock }
    let(:local_filename) { "filename.zip" }
    let(:object) { mock }
    let(:config) do
      FunctionConfig.new(name: "filename", bucket: "test", s3_archive_name: "function.zip")
    end
    let(:expected) do
      {
        s3_bucket: "test",
        s3_key: "/deployments/1234567890/filename/function.zip"
      }
    end

    subject { S3Pusher.new(client: s3, git: git, config: config) }

    before do
      git.stubs(:sha).returns("1234567890")
    end

    describe "#push" do
      before do
        Aws::S3::Object.any_instance.stubs(:exists?).returns(false, true)
        Aws::S3::Object.any_instance.expects(:upload_file).with("filename.zip")
      end

      it "uploads the file and returns the uploaded configuration" do
        result = subject.push(local_filename: local_filename)
        assert_equal(result, expected)
      end
    end

    describe "#output" do
      describe "when an object does not exist" do
        before do
          Aws::S3::Object.any_instance.stubs(:exists?).returns(false)
        end
        it "returns an empty hash" do
          result = subject.output
          assert_equal(result, {})
        end
      end

      describe "when an object does exist" do
        before do
          Aws::S3::Object.any_instance.stubs(:exists?).returns(true)
        end
        it "returns the s3 object details" do
          result = subject.output
          assert_equal(result, expected)
        end
      end
    end
  end
end
