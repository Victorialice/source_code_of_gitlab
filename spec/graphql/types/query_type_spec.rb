require 'spec_helper'

describe GitlabSchema.types['Query'] do
  it 'is called Query' do
    expect(described_class.graphql_name).to eq('Query')
  end

  it { is_expected.to have_graphql_fields(:project, :echo) }

  describe 'project field' do
    subject { described_class.fields['project'] }

    it 'finds projects by full path' do
      is_expected.to have_graphql_arguments(:full_path)
      is_expected.to have_graphql_type(Types::ProjectType)
      is_expected.to have_graphql_resolver(Resolvers::ProjectResolver)
    end

    it 'authorizes with read_project' do
      is_expected.to require_graphql_authorizations(:read_project)
    end
  end
end
