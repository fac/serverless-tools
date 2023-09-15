# frozen_string_literal: true

require_relative "./system_call"
require_relative "../logging"

module ServerlessTools
  module Deployer
    class EcrPusher
      include SystemCall

      def initialize(client:, git:, config:)
        @client = client
        @git = git
        @config = config
      end

      def push(local_image_name:)
        system_call "docker tag #{local_image_name} #{tagged_image_uri}"
        system_call "aws ecr get-login-password | docker login --username AWS --password-stdin #{repository_uri}"
        system_call "docker push #{tagged_image_uri}"
        asset
      end

      def output
        tags = image_tags
        if tags.include?(tag)
          return asset
        end
        Logging.logger.debug("Unable to find tag #{tag} in #{tags}")
        {}
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
