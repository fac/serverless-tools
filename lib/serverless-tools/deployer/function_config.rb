# frozen_string_literal: true

module ServerlessTools
  module Deployer
    FunctionConfig = Struct.new(:repo, :s3_archive_name, :handler_file, :bucket, :name, keyword_init: true) do
      def local_filename
        "#{name}.zip"
      end

      def s3_key(git_sha:)
        "#{repo}/deployments/#{git_sha}/#{name}/#{s3_archive_name}"
      end
    end
  end
end
