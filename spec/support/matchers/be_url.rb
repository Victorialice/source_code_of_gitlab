RSpec::Matchers.define :be_url do |_|
  match do |actual|
    URI.parse(actual) rescue false
  end
end
