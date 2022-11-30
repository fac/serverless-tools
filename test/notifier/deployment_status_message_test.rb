require "minitest/autorun"
require "mocha/minitest"

require "serverless-tools/notifier/deployment_status_message"

module ServerlessTools::Notifier
  describe DeploymentStatusMessage do
    let(:mock_git_client) { mock("git_client") }
    let(:repo_name) { "fac/repo-name" }
    let(:run_id) { 123 }
    let(:sha) { "dab326e948974caba97eae82a1431d0bfcdeff36" }
    let(:deploy_info) do
      "<https://github.com/fac/repo-name/actions/runs/3534407323/attempts/1|fac/repo-name/branch-name #643> " \
      "for @terry.pratchett\n" \
      "⚙️ <https://github.com/fac/repo-name/commit/dab326e948974caba97eae82a1431d0bfcdeff36|dab326e9489> " \
      "Commit message " \
      "(<https://github.com/fac/repo-name/pull/182|#182>)"
    end

    subject do
      DeploymentStatusMessage.new(
        git_client: mock_git_client,
        repo_name: repo_name,
        run_id: run_id
      )
    end

    describe "#text_for_status" do
      describe "for an invalid status" do
        it "raises an error for an unknown status" do
          error = expect{ subject.text_for_status("invalid") }.must_raise(ArgumentError)

          expected_message = "Unknown status: 'invalid'. Accepted values: 'start', 'success', 'failure'"
          assert_equal(error.message, expected_message)
        end
      end

      describe "for a valid status" do
        before do
          mock_git_client
            .expects(:workflow_run).with(repo_name, run_id)
            .returns({
              "html_url" => "https://github.com/fac/repo-name/actions/runs/3534407323",
              "run_attempt" => 1,
              "run_number" => 643,
              "head_branch" => "branch-name",
              "head_sha" => sha,
              "pull_requests" => [
                {
                  "number" => 182,
                }
              ],
              "head_commit" => {
                "message" => "Commit message",
                "author" => {
                  "name" => "Terry Pratchett"
                }
              },
              "repository" => {
                "html_url" => "https://github.com/fac/repo-name"
              }
            })
        end

        it "returns a message for deployment start" do
          expected = "🏗️ *DEPLOYING* #{deploy_info}"

          assert_equal(subject.text_for_status("start"), expected)
        end

        it "returns a message for deployment success" do
          expected = "🎉 *DEPLOYED* #{deploy_info}"

          assert_equal(subject.text_for_status("success"), expected)
        end

        it "returns a message for deployment failure" do
          expected = "❌ *FAILED* #{deploy_info}"

          assert_equal(subject.text_for_status("failure"), expected)
        end
      end

      describe "when pull request info is missing" do
        before do
          mock_git_client
            .expects(:workflow_run).with(repo_name, run_id)
            .returns({
              "html_url" => "https://github.com/fac/repo-name/actions/runs/3534407323",
              "run_attempt" => 1,
              "run_number" => 643,
              "head_branch" => "branch-name",
              "display_title" => "Commit message (#182)",
              "head_sha" => sha,
              "pull_requests" => [],
              "head_commit" => {
                "message" => "Commit message",
                "author" => {
                  "name" => "Terry Pratchett"
                }
              },
              "repository" => {
                "html_url" => "https://github.com/fac/repo-name"
              }
            })
        end

        it "still includes all the expected details in the message" do
          expected = "🏗️ *DEPLOYING* #{deploy_info}"

          assert_equal(subject.text_for_status("start"), expected)
        end
      end
    end
  end
end
