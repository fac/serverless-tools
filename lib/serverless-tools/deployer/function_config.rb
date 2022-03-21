# frozen_string_literal: true

module ServerlessTools
  module Deployer
    FunctionConfig = Struct.new(:repo, :s3_archive_name, :handler_file, :bucket, :name, keyword_init: true) do
      def runtime
        unless handler_file.nil?
          return "ruby" if handler_file.split(".").last == "rb"
        end
      end
    end
  end
end
