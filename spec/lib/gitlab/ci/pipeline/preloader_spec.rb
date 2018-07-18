# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Pipeline::Preloader do
  let(:stage) { double(:stage) }
  let(:commit) { double(:commit) }

  let(:pipeline) do
    double(:pipeline, commit: commit, stages: [stage])
  end

  describe '.preload!' do
    context 'when preloading multiple commits' do
      let(:project) { create(:project, :repository) }

      it 'preloads all commits once' do
        expect(Commit).to receive(:decorate).once.and_call_original

        pipelines = [build_pipeline(ref: 'HEAD'),
                     build_pipeline(ref: 'HEAD~1')]

        described_class.preload!(pipelines)
      end

      def build_pipeline(ref:)
        build_stubbed(:ci_pipeline, project: project, sha: project.commit(ref).id)
      end
    end

    it 'preloads commit authors and number of warnings' do
      expect(commit).to receive(:lazy_author)
      expect(pipeline).to receive(:number_of_warnings)
      expect(stage).to receive(:number_of_warnings)

      described_class.preload!([pipeline])
    end

    it 'returns original collection' do
      allow(commit).to receive(:lazy_author)
      allow(pipeline).to receive(:number_of_warnings)
      allow(stage).to receive(:number_of_warnings)

      pipelines = [pipeline, pipeline]

      expect(described_class.preload!(pipelines)).to eq pipelines
    end
  end
end
