# frozen_string_literal: true

module ServerlessTools
  module Deployer
    module SystemCall
      # system_call wraps the Kernel system method
      # to ensure we're consistently calling out
      # to the system and raising errors.

      # The deployer calls out to the system in a
      # number of places and we want to ensure any
      # errors by the sub proceess are raised accordingly.
      def system_call(cmd)
        system(cmd, exception: true)
      end
    end
  end
end
