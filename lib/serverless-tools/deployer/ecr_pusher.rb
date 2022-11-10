# frozen_string_literal: true

module ServerlessTools
  module Deployer
    class EcrPusher
      def initialize(client:, git:, config:)
        @client = client
        @git = git
        @config = config
      end

      def push(local_image_name:)
        system("docker tag #{local_image_name} #{tagged_image_uri}")
        system("docker push #{tagged_image_uri}")
        asset
      end

      def output
        return {} unless image_tags.include?(tag)
        asset
      end

      private

      def asset
        {
          image_uri: tagged_image_uri,
        }
      end

      def image_tags
        client.describe_images(
          repository_name: config.repo,
          registry_id: config.registry_id
        ).image_details.flat_map(&:image_tags)
      end

      def tagged_image_uri
        @tagged_image_uri ||= "#{repository_uri}:#{tag}"
      end

      def repository_uri
        @repository_uri ||= client.describe_repositories(
          repository_names: [config.repo],
          registry_id: config.registry_id
        ).repositories.first.repository_uri
      end

      def tag
        git.short_sha
      end

      attr_reader :client, :git, :config
    end
  end
end
