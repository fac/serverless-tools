require "minitest/autorun"
require "mocha/minitest"
require "serverless-tools/deployer/overrides"

module ServerlessTools
  module Deployer
    describe "Overrides" do
      describe "by default" do
        subject { Overrides.new() }

        it "force? equals false" do
          assert_equal(subject.force?, false)
        end
      end

      describe "when provided with a truthy force option" do
        subject { Overrides.new(force: true) }

        it "force? equals true" do
          assert_equal(subject.force?, true)
        end
      end

      describe "when provided with a falsey force option" do
        subject { Overrides.new(force: false) }

        it "force? equals false" do
          assert_equal(subject.force?, false)
        end
      end
    end
  end
end
