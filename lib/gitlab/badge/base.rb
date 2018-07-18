module Gitlab
  module Badge
    class Base
      def entity
        raise NotImplementedError
      end

      def status
        raise NotImplementedError
      end

      def metadata
        raise NotImplementedError
      end

      def template
        raise NotImplementedError
      end
    end
  end
end
