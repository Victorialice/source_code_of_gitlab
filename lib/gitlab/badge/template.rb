module Gitlab
  module Badge
    ##
    # Abstract template class for badges
    #
    class Template
      def initialize(badge)
        @entity = badge.entity
        @status = badge.status
      end

      def key_text
        raise NotImplementedError
      end

      def value_text
        raise NotImplementedError
      end

      def key_width
        raise NotImplementedError
      end

      def value_width
        raise NotImplementedError
      end

      def value_color
        raise NotImplementedError
      end

      def key_color
        '#555'
      end

      def key_text_anchor
        key_width / 2
      end

      def value_text_anchor
        key_width + (value_width / 2)
      end

      def width
        key_width + value_width
      end
    end
  end
end
