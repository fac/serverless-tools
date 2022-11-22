# frozen_string_literal: true
require "octokit"

module ServerlessTools
  module Notifier
    class Message
      def initialize(git_client: Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"]), repo_name:, run_id:)
        @git_client = git_client
        @repo_name = repo_name
        @run_id = run_id
      end

      def text_for_status(status)
        case status
        when "start"
          ":building_construction: *DEPLOYING* #{deployment_details}"
        when "success"
          ":tada: *DEPLOYED* #{deployment_details}"
        when "failure"
          ":x: *FAILED* #{deployment_details}"
        else
          raise ArgumentError, "Unknown status: '#{status}'. Accepted values: 'start', 'success', 'failure'"
        end
      end

      private

      def workflow_run_info
        @workflow_run_info ||= @git_client.workflow_run(@repo_name, @run_id)
      end

      def workflow_run_markdown
        run_url = "#{workflow_run_info["html_url"]}/attempts/#{workflow_run_info["run_attempt"]}"
        ref = workflow_run_info["pull_requests"][0]["head"]["ref"]
        run_number = workflow_run_info["run_number"]
        slack_name = workflow_run_info["head_commit"]["author"]["name"]
                      .split(" ")
                      .map(&:downcase)
                      .join(".")
                      .delete("'")

        "<#{run_url}|#{@repo_name}/#{ref} ##{run_number}> for @#{slack_name}"
      end

      def commit_markdown
        sha = workflow_run_info["head_sha"]
        short_sha = sha[0, 11]
        repo_url = workflow_run_info["repository"]["html_url"]
        commit_msg = @git_client.commit(@repo_name, sha)["commit"]["message"]

        ":github: <#{repo_url}/commit/#{sha}|#{short_sha}> #{commit_msg}"
      end

      def pr_markdown
        pr_number = workflow_run_info["pull_requests"][0]["number"]
        repo_url = workflow_run_info["repository"]["html_url"]

        "<#{repo_url}/pull/#{pr_number}|##{pr_number}>"
      end

      def deployment_details
        @deployment_details ||= "#{workflow_run_markdown}\n#{commit_markdown} (#{pr_markdown})"
      end
    end
  end
end
