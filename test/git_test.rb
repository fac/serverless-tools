require "minitest/autorun"
require "mocha/minitest"

require "serverless-tools/git"

describe "Git" do
  describe "#sha" do
    it "returns a value" do
      git = ServerlessTools::Git.new

      # This will call the git client so we're just checking that
      # something is returned.
      assert git.sha != nil
      assert git.sha.class.name == "String"
    end
  end
end
