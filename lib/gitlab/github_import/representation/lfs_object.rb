# frozen_string_literal: true

module Gitlab
  module GithubImport
    module Representation
      class LfsObject
        include ToHash
        include ExposeAttribute

        attr_reader :attributes

        expose_attribute :oid, :download_link

        # Builds a lfs_object
        def self.from_api_response(lfs_object)
          new({ oid: lfs_object[0], download_link: lfs_object[1] })
        end

        # Builds a new lfs_object using a Hash that was built from a JSON payload.
        def self.from_json_hash(raw_hash)
          new(Representation.symbolize_hash(raw_hash))
        end

        # attributes - A Hash containing the raw lfs_object details. The keys of this
        #              Hash must be Symbols.
        def initialize(attributes)
          @attributes = attributes
        end
      end
    end
  end
end
