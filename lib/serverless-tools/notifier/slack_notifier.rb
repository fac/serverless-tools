# frozen_string_literal: true
require "slack-ruby-client"

module ServerlessTools
  module Notifier
    class SlackNotifier
      def initialize(slack_client: Slack::Web::Client.new(token: ENV["SLACK_TOKEN"]))
        @slack_client = slack_client
      end

      def notify(channel:, username:, text:)
        @slack_client.chat_postMessage(
          channel: channel,
          username: username,
          text: text,
          link_names: true,
          icon_emoji: ":ship:"
        )
      end
    end
  end
end
