# frozen_string_literal: true

module ServerlessTools
  module Deployer
    class RubyBuilder
      def build(config:)
        `bundle`
        `zip -r "#{local_filename(config)}" #{config.handler_file} lib vendor/`
      end

      def local_filename(config)
        "#{config.name}.zip"
      end
    end
  end
end
