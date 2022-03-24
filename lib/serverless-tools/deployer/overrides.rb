# frozen_string_literal: true

module ServerlessTools
  module Deployer
    Overrides = Struct.new(:force, :filename, keyword_init: true) do
      def force?
        !!force
      end
    end
  end
end
