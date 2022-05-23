# frozen_string_literal: true

module ServerlessTools
  module Deployer
    FunctionConfig = Struct.new(
      :repo,
      :s3_archive_name,
      :handler_file,
      :bucket,
      :name,
      :dockerfile,
      keyword_init: true
    ) do
      def runtime
        return "docker" unless dockerfile.nil?

        unless handler_file.nil?
          if file_extension(handler_file) == "rb"
            return "ruby"
          elsif file_extension(handler_file) == "py"
            return "python"
        end
      end

      private

      def file_extension(file_name)
        file_name.split(".").last
      end
    end
  end
end
