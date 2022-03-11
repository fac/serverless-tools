# frozen_string_literal: true

module ServerlessTools
  module Deployer
    class RubyBuilder
      def build(config:)
        `bundle`
        `zip -r "#{config.local_filename}" #{config.handler_file} lib vendor/`
      end
    end
  end
end
