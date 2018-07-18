module Gitlab
  module Verify
    class BatchVerifier
      attr_reader :batch_size, :start, :finish

      def initialize(batch_size:, start: nil, finish: nil)
        @batch_size = batch_size
        @start = start
        @finish = finish

        fix_google_api_logger
      end

      # Yields a Range of IDs and a Hash of failed verifications (object => error)
      def run_batches(&blk)
        all_relation.in_batches(of: batch_size, start: start, finish: finish) do |batch| # rubocop: disable Cop/InBatches
          range = batch.first.id..batch.last.id
          failures = run_batch_for(batch)

          yield(range, failures)
        end
      end

      def name
        raise NotImplementedError.new
      end

      def describe(_object)
        raise NotImplementedError.new
      end

      private

      def run_batch_for(batch)
        batch.map { |upload| verify(upload) }.compact.to_h
      end

      def verify(object)
        local?(object) ? verify_local(object) : verify_remote(object)
      rescue => err
        failure(object, err.inspect)
      end

      def verify_local(object)
        expected = expected_checksum(object)
        actual = actual_checksum(object)

        return failure(object, 'Checksum missing') unless expected.present?
        return failure(object, 'Checksum mismatch') unless expected == actual

        success
      end

      # We don't calculate checksum for remote objects, so just check existence
      def verify_remote(object)
        return failure(object, 'Remote object does not exist') unless remote_object_exists?(object)

        success
      end

      def success
        nil
      end

      def failure(object, message)
        [object, message]
      end

      # It's already set to Logger::INFO, but acts as if it is set to
      # Logger::DEBUG, and this fixes it...
      def fix_google_api_logger
        if Object.const_defined?('Google::Apis')
          Google::Apis.logger.level = Logger::INFO
        end
      end

      # This should return an ActiveRecord::Relation suitable for calling #in_batches on
      def all_relation
        raise NotImplementedError.new
      end

      # Should return true if the object is stored locally
      def local?(_object)
        raise NotImplementedError.new
      end

      # The checksum we expect the object to have
      def expected_checksum(_object)
        raise NotImplementedError.new
      end

      # The freshly-recalculated checksum of the object
      def actual_checksum(_object)
        raise NotImplementedError.new
      end

      # Be sure to perform a hard check of the remote object (don't just check DB value)
      def remote_object_exists?(object)
        raise NotImplementedError.new
      end
    end
  end
end
