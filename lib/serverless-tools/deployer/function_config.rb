# frozen_string_literal :true

module ServerlessTools
  module Deployer
    FunctionConfig = Struct.new(
      :repo,
      :s3_archive_name,
      :handler_file,
      :bucket,
      :name,
      keyword_init: true
    )
  end
end
