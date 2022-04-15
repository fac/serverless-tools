require "minitest/autorun"
require "mocha/minitest"

require "serverless-tools/deployer/docker_builder"

module ServerlessTools::Deployer
  describe "DockerBuilder" do
    let(:config) {
        FunctionConfig.new(name: "function_one", repo: "function_one_ecr_repo", dockerfile: "Dockerfile")
    }
    let(:subject) { DockerBuilder.new(config: config) }

    describe "#build" do
      it "builds the Docker image" do
        subject.expects(:system).with(
          "docker build . -f Dockerfile -t function_one_ecr_repo:latest"
        )
        subject.build
      end

      describe "#output" do
        it "returns local image name" do
          expected_output = {local_image_name: "function_one_ecr_repo:latest"}
          assert_equal(expected_output, subject.output)
        end
      end
    end
  end
end
