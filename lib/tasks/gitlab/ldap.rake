namespace :gitlab do
  namespace :ldap do
    desc 'GitLab | LDAP | Rename provider'
    task :rename_provider, [:old_provider, :new_provider] => :environment  do |_, args|
      old_provider = args[:old_provider] ||
        prompt('What is the old provider? Ex. \'ldapmain\': '.color(:blue))
      new_provider = args[:new_provider] ||
        prompt('What is the new provider ID? Ex. \'ldapcustom\': '.color(:blue))
      puts '' # Add some separation in the output

      identities = Identity.where(provider: old_provider)
      identity_count = identities.count

      if identities.empty?
        puts "Found no user identities with '#{old_provider}' provider."
        puts 'Please check the provider name and try again.'
        exit 1
      end

      plural_id_count = ActionController::Base.helpers.pluralize(identity_count, 'user')

      unless ENV['force'] == 'yes'
        puts "#{plural_id_count} with provider '#{old_provider}' will be updated to '#{new_provider}'"
        puts 'If the new provider is incorrect, users will be unable to sign in'
        ask_to_continue
        puts ''
      end

      updated_count = identities.update_all(provider: new_provider)

      if updated_count == identity_count
        puts 'User identities were successfully updated'.color(:green)
      else
        plural_updated_count = ActionController::Base.helpers.pluralize(updated_count, 'user')
        puts 'Some user identities could not be updated'.color(:red)
        puts "Successfully updated #{plural_updated_count} out of #{plural_id_count} total"
      end
    end
  end
end
