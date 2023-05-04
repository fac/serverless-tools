# frozen_string_literal: true
require "octokit"

module ServerlessTools
  module Notifier
    class DeploymentStatusMessage
      def initialize(git_client: Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"]), repo_name:, run_id:)
        @git_client = git_client
        @repo_name = repo_name
        @run_id = run_id
      end

      def text_for_status(status)
        case status
        when "start"
          "🏗️ *DEPLOYING* #{deployment_details}"
        when "success"
          "🎉 *DEPLOYED* #{deployment_details}"
        when "failure"
          "❌ *FAILED* #{deployment_details}"
        else
          raise ArgumentError, "Unknown status: '#{status}'. Accepted values: 'start', 'success', 'failure'"
        end
      end

      private

      def workflow_run_info
        @workflow_run_info ||= @git_client.workflow_run(@repo_name, @run_id)
      end

      def repo_url
        @repo_url ||= workflow_run_info["repository"]["html_url"]
      end

      def pr_markdown
        commit_msg = workflow_run_info["head_commit"]["message"]
        pull_requests = workflow_run_info["pull_requests"]

        if pull_requests.any?
          # For certain actions (like pushing to the repo), the workflow run info contains direct references to
          # the relevant pull request (which includes the PR number but not the title). In this case, we
          # combine the message of the head commit with a link to the PR.
          pr_number = pull_requests[0]["number"]
          "#{commit_msg} (<#{repo_url}/pull/#{pr_number}|##{pr_number}>)"
        else
          # When merging into the main branch, we don't get a reference to the PR directly, however the PR number
          # should appear in the message of the head commit.
          matches = commit_msg.match(%r{\(#(?<pr_number>\d{1,})\)})
          pr_number = matches[:pr_number] if matches

          # If we manage to find the PR number in the commit, we can add a link to it in the deployment message.
          # Otherwise, we just return the bare commit message.
          pr_number ? commit_msg.sub("##{pr_number}", "<#{repo_url}/pull/#{pr_number}|##{pr_number}>") : commit_msg
        end
      end

      def workflow_run_markdown
        run_url = "#{workflow_run_info["html_url"]}/attempts/#{workflow_run_info["run_attempt"]}"
        head_branch = workflow_run_info["head_branch"]
        run_number = workflow_run_info["run_number"]

        delimiters = [" ", /(?=[A-Z])/]
        slack_name = workflow_run_info["head_commit"]["author"]["name"]
                      .gsub( /\d+/,"")
                      .split(Regexp.union(delimiters))
                      .map(&:downcase)
                      .join(".")
                      .delete("'")

        "<#{run_url}|#{@repo_name}/#{head_branch} ##{run_number}> for @#{slack_name}"
      end

      def commit_markdown
        sha = workflow_run_info["head_commit"]["id"]
        short_sha = sha[0, 11]

        "<#{repo_url}/commit/#{sha}|#{short_sha}>"
      end

      def deployment_details
        @deployment_details ||= "#{workflow_run_markdown}\n⚙️ #{commit_markdown} #{pr_markdown}"
      end
    end
  end
end
