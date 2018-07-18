RSpec.configure do |config|
  config.before(:each) do |example|
    if example.metadata[:disable_gitaly]
      # Use 'and_wrap_original' to make sure the arguments are valid
      allow(Gitlab::GitalyClient).to receive(:feature_enabled?).and_wrap_original { |m, *args| m.call(*args) && false }
    else
      next if example.metadata[:skip_gitaly_mock]

      # Use 'and_wrap_original' to make sure the arguments are valid
      allow(Gitlab::GitalyClient).to receive(:feature_enabled?).and_wrap_original do |m, *args|
        m.call(*args)
        !Gitlab::GitalyClient.explicit_opt_in_required.include?(args.first)
      end
    end
  end
end
