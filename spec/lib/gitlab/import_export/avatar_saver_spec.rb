require 'spec_helper'

describe Gitlab::ImportExport::AvatarSaver do
  let(:shared) { project.import_export_shared }
  let(:export_path) { "#{Dir.tmpdir}/project_tree_saver_spec" }
  let(:project_with_avatar) { create(:project, avatar: fixture_file_upload("spec/fixtures/dk.png", "image/png")) }
  let(:project) { create(:project) }

  before do
    FileUtils.mkdir_p("#{shared.export_path}/avatar/")
    allow_any_instance_of(Gitlab::ImportExport).to receive(:storage_path).and_return(export_path)
  end

  after do
    FileUtils.rm_rf("#{shared.export_path}/avatar")
  end

  it 'saves a project avatar' do
    described_class.new(project: project_with_avatar, shared: shared).save

    expect(File).to exist("#{shared.export_path}/avatar/dk.png")
  end

  it 'is fine not to have an avatar' do
    expect(described_class.new(project: project, shared: shared).save).to be true
  end
end
