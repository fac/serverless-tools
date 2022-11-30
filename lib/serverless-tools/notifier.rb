# frozen_string_literal: true
require "slack-ruby-client"
require_relative "./notifier/deployment_status_message"
require_relative "./notifier/slack_notifier"

module ServerlessTools
  module Notifier
    def self.notify(status:, repo_name:, channel:, run_id:)
      text = DeploymentStatusMessage.new(repo_name: repo_name, run_id: run_id).text_for_status(status)

      SlackNotifier.new.notify(channel: channel, username: repo_name, text: text)
    end
  end
end
