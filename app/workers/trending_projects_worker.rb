# frozen_string_literal: true

class TrendingProjectsWorker
  include ApplicationWorker
  include CronjobQueue

  def perform
    Rails.logger.info('Refreshing trending projects')

    TrendingProject.refresh!
  end
end
