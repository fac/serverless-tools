require "minitest/autorun"
require "mocha/minitest"

require "serverless-tools/notifier/slack_notifier"

module ServerlessTools::Notifier
  describe SlackNotifier do
    let(:mock_slack_client) { mock("slack_client") }
    let(:channel) { "test channel" }
    let(:username) { "test username" }
    let(:text) { "test message" }

    subject { SlackNotifier.new(slack_client: mock_slack_client) }

    describe "#notify" do
      before do
        mock_slack_client
        .expects(:chat_postMessage)
        .with(
          channel: channel,
          username: username,
          text: text,
          link_names: true,
          icon_emoji: ":ship:"
        )
      end

      it "correctly calls the client" do
        subject.notify(
          channel: channel,
          username: username,
          text: text
        )
      end
    end
  end
end
