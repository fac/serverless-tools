# required while Mocha is stuck on 1.6
# see https://github.com/fac/serverless-tools/issues/180
ENV["MT_COMPAT"] = "1"

require "minitest/autorun"
require "mocha/minitest"

require "serverless-tools/comment"

describe "Comment" do
  let(:git) { mock() }
  let(:key) { "/key/to/s3/object/function.zip" }
  let(:function) { "example_function" }
  let(:function_json) do
    {
      example_function_status: "Succeeded",
      example_function_key: key,
    }.to_json
  end

  describe "#build" do
    before do
      git.stubs(:sha).returns("123")
    end

    it "returns a value" do
      comment = ServerlessTools::Comment.new(git: git)

      expected_result = <<~EOF.strip
        Functions updated for sha: 123
        > **#{function}_status**: Succeeded
        > **#{function}_key**: #{key}
      EOF

      assert_equal(comment.build(function_json), expected_result)
    end

    it "yields the comment line by line if given a block" do
      comment = ServerlessTools::Comment.new(git: git)

      expected_result = [
        "Functions updated for sha: 123",
        "> **#{function}_status**: Succeeded",
        "> **#{function}_key**: #{key}"
      ]

      result = []

      comment.build(function_json) do |line|
        result << line
      end

      assert_equal(result, expected_result)
    end
  end
end
