require 'spec_helper'

describe Gitlab::Serializer::Ci::Variables do
  subject do
    described_class.load(described_class.dump(object))
  end

  let(:object) do
    [{ key: :key, value: 'value', public: true },
     { key: 'wee', value: 1, public: false }]
  end

  it 'converts keys into strings' do
    is_expected.to eq([
      { key: 'key', value: 'value', public: true },
      { key: 'wee', value: 1, public: false }
    ])
  end
end
