class WebHook < ActiveRecord::Base
  include Sortable

  has_many :web_hook_logs, dependent: :destroy # rubocop:disable Cop/ActiveRecordDependent

  validates :url, presence: true, public_url: { allow_localhost: lambda(&:allow_local_requests?),
                                                allow_local_network: lambda(&:allow_local_requests?) }

  validates :token, format: { without: /\n/ }

  def execute(data, hook_name)
    WebHookService.new(self, data, hook_name).execute
  end

  def async_execute(data, hook_name)
    WebHookService.new(self, data, hook_name).async_execute
  end

  # SystemHooksService.new.execute_hooks(data, hooks_scope)

  # Allow urls pointing localhost and the local network
  def allow_local_requests?
    false
  end
end
