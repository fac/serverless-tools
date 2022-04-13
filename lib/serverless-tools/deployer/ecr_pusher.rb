# frozen_string_literal: true
require "aws-sdk-ecr"

module ServerlessTools
  module Deployer
    class EcrPusher
      def initialize(client:, git:, config:)
        @client = client
        @git = git
        @config = config
      end

      def push(local_image_name:)
        if image_tags.include?(tag)
          puts "Did not upload #{tagged_image_uri} as it already exists!"
        else
          system("docker tag #{local_image_name} #{tagged_image_uri}")
          system("docker push #{tagged_image_uri}")
        end
        output
      end

      def output
        return {} unless image_tags.include?(tag)
        {
          image_uri: tagged_image_uri,
        }
      end

      private

      def image_tags
        client.describe_images(repository_name: config.repo).image_details.flat_map(&:image_tags)
      end

      def tagged_image_uri
        @tagged_image_uri ||= "#{repository_uri}:#{tag}"
      end

      def repository_uri
        @repository_uri ||= client.describe_repositories(
          repository_names: [config.repo]
        ).repositories.first.repository_uri
      end

      def tag
        git.short_sha
      end

      attr_reader :client, :git, :config
    end
  end
end
