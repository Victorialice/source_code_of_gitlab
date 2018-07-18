# A note on merge request or commit diffs
#
# A note of this type can be resolvable.
class DiffNote < Note
  include NoteOnDiff
  include Gitlab::Utils::StrongMemoize

  NOTEABLE_TYPES = %w(MergeRequest Commit).freeze

  serialize :original_position, Gitlab::Diff::Position # rubocop:disable Cop/ActiveRecordSerialize
  serialize :position, Gitlab::Diff::Position # rubocop:disable Cop/ActiveRecordSerialize
  serialize :change_position, Gitlab::Diff::Position # rubocop:disable Cop/ActiveRecordSerialize

  validates :original_position, presence: true
  validates :position, presence: true
  validates :line_code, presence: true, line_code: true, if: :on_text?
  validates :noteable_type, inclusion: { in: NOTEABLE_TYPES }
  validate :positions_complete
  validate :verify_supported
  validate :diff_refs_match_commit, if: :for_commit?

  before_validation :set_original_position, on: :create
  before_validation :update_position, on: :create, if: :on_text?
  before_validation :set_line_code, if: :on_text?
  after_save :keep_around_commits
  after_commit :create_diff_file, on: :create

  def discussion_class(*)
    DiffDiscussion
  end

  %i(original_position position change_position).each do |meth|
    define_method "#{meth}=" do |new_position|
      if new_position.is_a?(String)
        new_position = JSON.parse(new_position) rescue nil
      end

      if new_position.is_a?(Hash)
        new_position = new_position.with_indifferent_access
        new_position = Gitlab::Diff::Position.new(new_position)
      end

      return if new_position == read_attribute(meth)

      super(new_position)
    end
  end

  def on_text?
    position.position_type == "text"
  end

  def on_image?
    position.position_type == "image"
  end

  def create_diff_file
    return unless should_create_diff_file?

    diff_file = fetch_diff_file
    diff_line = diff_file.line_for_position(self.original_position)

    creation_params = diff_file.diff.to_hash
      .except(:too_large)
      .merge(diff: diff_file.diff_hunk(diff_line))

    create_note_diff_file(creation_params)
  end

  def diff_file
    strong_memoize(:diff_file) do
      enqueue_diff_file_creation_job if should_create_diff_file?

      fetch_diff_file
    end
  end

  def diff_line
    @diff_line ||= diff_file&.line_for_position(self.original_position)
  end

  def original_line_code
    return unless on_text?

    self.diff_file.line_code(self.diff_line)
  end

  def active?(diff_refs = nil)
    return false unless supported?
    return true if for_commit?

    diff_refs ||= noteable.diff_refs

    self.position.diff_refs == diff_refs
  end

  def created_at_diff?(diff_refs)
    return false unless supported?
    return true if for_commit?

    self.original_position.diff_refs == diff_refs
  end

  private

  def enqueue_diff_file_creation_job
    # Avoid enqueuing multiple file creation jobs at once for a note (i.e.
    # parallel calls to `DiffNote#diff_file`).
    lease = Gitlab::ExclusiveLease.new("note_diff_file_creation:#{id}", timeout: 1.hour.to_i)
    return unless lease.try_obtain

    CreateNoteDiffFileWorker.perform_async(id)
  end

  def should_create_diff_file?
    on_text? && note_diff_file.nil? && self == discussion.first_note
  end

  def fetch_diff_file
    if note_diff_file
      diff = Gitlab::Git::Diff.new(note_diff_file.to_hash)
      Gitlab::Diff::File.new(diff,
                             repository: project.repository,
                             diff_refs: original_position.diff_refs)
    elsif created_at_diff?(noteable.diff_refs)
      # We're able to use the already persisted diffs (Postgres) if we're
      # presenting a "current version" of the MR discussion diff.
      # So no need to make an extra Gitaly diff request for it.
      # As an extra benefit, the returned `diff_file` already
      # has `highlighted_diff_lines` data set from Redis on
      # `Diff::FileCollection::MergeRequestDiff`.
      noteable.diffs(paths: original_position.paths, expanded: true).diff_files.first
    else
      original_position.diff_file(self.project.repository)
    end
  end

  def supported?
    for_commit? || self.noteable.has_complete_diff_refs?
  end

  def set_original_position
    self.original_position = self.position.dup unless self.original_position&.complete?
  end

  def set_line_code
    self.line_code = self.position.line_code(self.project.repository)
  end

  def update_position
    return unless supported?
    return if for_commit?

    return if active?

    tracer = Gitlab::Diff::PositionTracer.new(
      project: self.project,
      old_diff_refs: self.position.diff_refs,
      new_diff_refs: self.noteable.diff_refs,
      paths: self.position.paths
    )

    result = tracer.trace(self.position)
    return unless result

    if result[:outdated]
      self.change_position = result[:position]
    else
      self.position = result[:position]
    end
  end

  def verify_supported
    return if supported?

    errors.add(:noteable, "doesn't support new-style diff notes")
  end

  def positions_complete
    return if self.original_position.complete? && self.position.complete?

    errors.add(:position, "is invalid")
  end

  def diff_refs_match_commit
    return if self.original_position.diff_refs == self.commit.diff_refs

    errors.add(:commit_id, 'does not match the diff refs')
  end

  def keep_around_commits
    project.repository.keep_around(self.original_position.base_sha)
    project.repository.keep_around(self.original_position.start_sha)
    project.repository.keep_around(self.original_position.head_sha)

    if self.position != self.original_position
      project.repository.keep_around(self.position.base_sha)
      project.repository.keep_around(self.position.start_sha)
      project.repository.keep_around(self.position.head_sha)
    end
  end
end
