require "minitest/autorun"
require "mocha/minitest"
require "aws-sdk-s3"

require "serverless-tools/deployer/s3_uploader"

describe "S3Uploader" do
  let(:s3) { Aws::S3::Client.new(stub_responses: true) }

  let(:object) { mock }
  describe "#upload" do
    it "uploads file to S3 object when object doesn't exist" do
      object.stubs(:exists?).returns(false)
      object.expects(:upload_file).with("filename.zip")

      uploader = ServerlessTools::Deployer::S3Uploader.new(object)
      uploader.upload("filename.zip")
    end

    it "does not upload object to S3 when it exists" do
      object.stubs(:exists?).returns(true)
      object.expects(:upload_file).never
      object.expects(:key).returns("some_key")

      uploader = ServerlessTools::Deployer::S3Uploader.new(object)
      uploader.upload("filename.zip")
    end
  end
end
