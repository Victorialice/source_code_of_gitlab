describe QA::Runtime::API::Request do
  include Support::StubENV

  before do
    stub_env('PERSONAL_ACCESS_TOKEN', 'a_token')
  end

  let(:client)  { QA::Runtime::API::Client.new('http://example.com') }
  let(:request) { described_class.new(client, '/users') }

  describe '#url' do
    it 'returns the full api request url' do
      expect(request.url).to eq 'http://example.com/api/v4/users?private_token=a_token'
    end
  end

  describe '#request_path' do
    it 'prepends the api path' do
      expect(request.request_path('/users')).to eq '/api/v4/users'
    end

    it 'adds the personal access token' do
      expect(request.request_path('/users', private_token: 'token'))
        .to eq '/api/v4/users?private_token=token'
    end

    it 'adds the oauth access token' do
      expect(request.request_path('/users', access_token: 'otoken'))
        .to eq '/api/v4/users?access_token=otoken'
    end

    it 'respects query parameters' do
      expect(request.request_path('/users?page=1')).to eq '/api/v4/users?page=1'
      expect(request.request_path('/users', private_token: 'token', foo: 'bar/baz'))
        .to eq '/api/v4/users?private_token=token&foo=bar%2Fbaz'
      expect(request.request_path('/users?page=1', private_token: 'token', foo: 'bar/baz'))
        .to eq '/api/v4/users?page=1&private_token=token&foo=bar%2Fbaz'
    end

    it 'uses a different api version' do
      expect(request.request_path('/users', version: 'other_version')).to eq '/api/other_version/users'
    end
  end
end
