module Types
  module Ci
    class PipelineStatusEnum < BaseEnum
      ::Ci::Pipeline.all_state_names.each do |state_symbol|
        value state_symbol.to_s.upcase, value: state_symbol.to_s
      end
    end
  end
end
