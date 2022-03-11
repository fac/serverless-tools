require "minitest/autorun"
require "mocha/minitest"
require "aws-sdk-s3"

require "serverless-tools/deployer/s3_pusher"
require "serverless-tools/deployer/function_config"

module ServerlessTools::Deployer
  describe "S3Pusher" do
    let(:s3) { Aws::S3::Client.new(stub_responses: true) }
    let(:config) do
      FunctionConfig.new(name: "filename", bucket: "test", s3_archive_name: "function.zip")
    end
    let(:git) { mock() }

    before do
      git.stubs(:sha).returns("1234567890")
    end

    let(:object) { mock }
    let(:subject) { S3Pusher.new(client: s3, git: git) }
    let(:expected) do
      {
        s3_bucket: "test",
        s3_key: "/deployments/1234567890/filename/function.zip"
      }
    end

    describe "#push" do
      describe "when an object doesn't exist" do
        before do
          Aws::S3::Object.any_instance.stubs(:exists?).returns(false)
          Aws::S3::Object.any_instance.expects(:upload_file).with("filename.zip")
        end

        it "uploads the file and returns the uploaded configuration" do
          result = subject.push(config: config)
          expected = {
            s3_bucket: "test",
            s3_key: "/deployments/1234567890/filename/function.zip"
          }
          assert_equal(result, expected)
        end
      end

      describe "when an object does exist" do
        it "does not upload a file to S3 and returns the configuration" do
          Aws::S3::Object.any_instance.stubs(:exists?).returns(true)
          Aws::S3::Object.any_instance.expects(:upload_file).never

          result = subject.push(config: config)
          assert_equal(result, expected)
        end
      end
    end
  end
end
