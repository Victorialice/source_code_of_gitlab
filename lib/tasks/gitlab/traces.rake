require 'logger'
require 'resolv-replace'

desc "GitLab | Archive legacy traces to trace artifacts"
namespace :gitlab do
  namespace :traces do
    task archive: :environment do
      logger = Logger.new(STDOUT)
      logger.info('Archiving legacy traces')

      Ci::Build.finished.without_archived_trace
        .order(id: :asc)
        .find_in_batches(batch_size: 1000) do |jobs|
        job_ids = jobs.map { |job| [job.id] }

        ArchiveTraceWorker.bulk_perform_async(job_ids)

        logger.info("Scheduled #{job_ids.count} jobs. From #{job_ids.min} to #{job_ids.max}")
      end
    end
  end
end
