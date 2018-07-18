module Gitlab
  module Prometheus
    class Metric
      include ActiveModel::Model

      attr_accessor :title, :required_metrics, :weight, :y_label, :queries

      validates :title, :required_metrics, :weight, :y_label, :queries, presence: true

      def initialize(params = {})
        super(params)
        @y_label ||= 'Values'
      end
    end
  end
end
