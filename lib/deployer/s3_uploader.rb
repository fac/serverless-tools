module Deployer
  class S3Uploader
    def initialize(object)
      @object = object
    end

    def upload(file)
      if object.exists?
        puts "Did not upload #{object.key} as it already exists!"
      else
        object.upload_file(file)
      end
    end

    private

    attr_reader :object
  end
end
