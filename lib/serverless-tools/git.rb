# frozen_string_literal: true
module ServerlessTools
  class Git
    def sha
      (`git rev-parse HEAD`).strip
    end
  end
end
