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
        unless handler_file.nil?
          case file_extension(handler_file)
          when "rb"
            "ruby"
          when "R"
            "r"
          end
        end
      end

      private

      def file_extension(file_name)
        file_name.split(".").last
      end
    end
  end
end
