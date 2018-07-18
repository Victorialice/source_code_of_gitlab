# Given a list of oids, this services links the existent Lfs Objects to the project
module Projects
  module LfsPointers
    class LfsLinkService < BaseService
      # Accept an array of oids to link
      #
      # Returns a hash with the same structure with oids linked
      def execute(oids)
        return {} unless project&.lfs_enabled?

        # Search and link existing LFS Object
        link_existing_lfs_objects(oids)
      end

      private

      def link_existing_lfs_objects(oids)
        existent_lfs_objects = LfsObject.where(oid: oids)

        return [] unless existent_lfs_objects.any?

        not_linked_lfs_objects = existent_lfs_objects.where.not(id: project.all_lfs_objects)
        project.all_lfs_objects << not_linked_lfs_objects

        existent_lfs_objects.pluck(:oid)
      end
    end
  end
end
