require "minitest/autorun"
require "mocha/minitest"
require "aws-sdk-ecr"

require "serverless-tools/deployer/ecr_pusher"
require "serverless-tools/deployer/function_config"

module ServerlessTools::Deployer
  describe "EcrPusher" do
    let(:ecr) { Aws::ECR::Client.new(stub_responses: true) }
    let(:git) { mock }
    let(:repo) { "serverless-tools" }
    let(:local_image_name) { "#{repo}:latest" }
    let(:registry_id) { "971677615731" }
    let(:registry_uri) { "#{registry_id}.dkr.ecr.eu-west-1.amazonaws.com" }
    let(:short_sha) { "1234567" }
    let(:config) { FunctionConfig.new(repo: repo, dockerfile: "Dockerfile", registry_id: registry_id) }
    let(:expected) { {image_uri: "#{registry_uri}/#{repo}:#{short_sha}"} }

    subject { EcrPusher.new(client: ecr, git: git, config: config) }

    before do
      git.stubs(:short_sha).returns(short_sha)
      ecr.stub_responses(:describe_repositories, { repositories: [{ repository_uri: "#{registry_uri}/#{repo}" }] })
    end

    describe "#push" do
      it "uploads the image and returns the uploaded configuration" do
        subject.expects(:system).with(
          "docker tag #{local_image_name} #{registry_uri}/#{repo}:#{short_sha}"
        )
        subject.expects(:system).with(
          "aws ecr get-login-password | docker login --username AWS --password-stdin #{registry_uri}/#{repo}"
        )
        subject.expects(:system).with(
          "docker push #{registry_uri}/#{repo}:#{short_sha}"
        )

        result = subject.push(local_image_name: local_image_name)

        assert_equal(result, expected)

        assert_equal(ecr.api_requests.first[:params], {
          repository_names: [repo],
          registry_id: registry_id,
        })
      end
    end

    describe "#output" do
      describe "when the image doesn't exist" do
        before do
          ecr.stub_responses(
            :describe_images,
            { image_details: [{ image_tags: [] }] },
            { image_details: [{ image_tags: [short_sha] }] }
          )
        end

        it "returns an empty hash" do
          assert_equal(subject.output, {})
        end
      end

      describe "when an image does exist" do
        before do
          ecr.stub_responses(
            :describe_images,
            { image_details: [{ image_tags: [short_sha] }] }
          )
        end

        it "returns the existing image URI" do
          assert_equal(subject.output, expected)
          assert_equal(ecr.api_requests.first[:params], {
            repository_name: repo,
            registry_id: registry_id,
          })
        end
      end
    end
  end
end
