class ImportExportUploader < AttachmentUploader
  EXTENSION_WHITELIST = %w[tar.gz].freeze

  def extension_whitelist
    EXTENSION_WHITELIST
  end

  def move_to_store
    true
  end

  def move_to_cache
    false
  end
end
