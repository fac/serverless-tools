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

  describe "#short_sha" do
    it "returns a string of the right length" do
      git = ServerlessTools::Git.new

      assert git.short_sha.class.name == "String"
      assert git.short_sha.length == 7
    end

    it "returns a short version of the full Git sha" do
      git = ServerlessTools::Git.new

      assert git.short_sha == git.sha[0..6]
    end
  end
end
