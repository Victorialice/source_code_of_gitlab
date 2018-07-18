module Gitlab
  module Template
    module Finders
      class BaseTemplateFinder
        def initialize(base_dir)
          @base_dir = base_dir
        end

        def list_files_for
          raise NotImplementedError
        end

        def read
          raise NotImplementedError
        end

        def find
          raise NotImplementedError
        end

        def category_directory(category)
          return @base_dir unless category.present?

          @base_dir + @categories[category]
        end

        class << self
          def filter_regex(extension)
            /#{Regexp.escape(extension)}\z/
          end
        end
      end
    end
  end
end
