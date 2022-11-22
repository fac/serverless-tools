require "minitest/autorun"
require "mocha/minitest"

require "serverless-tools/notifier"
require "serverless-tools/notifier/message"
require "serverless-tools/notifier/slack_notifier"

module ServerlessTools
  describe Notifier do
    let(:status) { "test status" }
    let(:channel) { "test channel" }
    let(:repo) { "test repo" }
    let(:text) { "test message" }

    describe "#notify" do
      it "sends a message to Slack" do
        Notifier::Message.any_instance.expects(:text_for_status).with(status).returns(text)
        Notifier::SlackNotifier.any_instance.expects(:notify).with(
          channel: channel,
          username: repo,
          text: text
        )

        Notifier.notify(status: status, repo_name: repo, channel: channel, run_id: 123)
      end
    end
  end
end
