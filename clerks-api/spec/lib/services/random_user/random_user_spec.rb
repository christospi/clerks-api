require 'rails_helper'
require 'webmock/rspec'

RSpec.describe RandomUser do
  let(:stub_url) { 'https://randomuser.me/api/' }
  let(:mocked_response) { File.read('spec/fixtures/random_user/response.json') }
  let(:url_params) { {} }

  before do
    stub_request(:get, /#{stub_url}/).with(query: hash_including(url_params)).
      to_return(status: 200, body: mocked_response, headers: {})
  end

  describe '.fetch_users' do
    context 'when no params are passed' do
      it 'performs a request with the default params' do
        expected_params = {
          'results' => described_class::DEFAULT_SIZE.to_s,
          'inc' => described_class::DEFAULT_FIELDS.join(',')
        }

        described_class.fetch_users

        expect(WebMock).to have_requested(:get, /#{stub_url}/).
          with(query: hash_including(expected_params)).once
      end

      it 'returns an array of users' do
        users = described_class.fetch_users
        expect(users).to be_an(Array)
      end
    end

    context 'when params are passed' do
      context 'when field params are all valid' do
        let(:fields) { described_class::ALLOWED_FIELDS.sample(2) }
        let(:url_params) { { inc: fields.join(',') } }

        it 'performs a request with the given params' do
          described_class.fetch_users(fields: fields)

          expect(WebMock).to have_requested(:get, /#{stub_url}/).
            with(query: hash_including(url_params)).once
        end
      end

      context 'when field params are all invalid' do
        let(:fields) { %w[unrecognized] }
        let(:url_params) { { inc: described_class::DEFAULT_FIELDS.join(',') } }

        it 'performs a request with the default params' do
          described_class.fetch_users(fields: fields)

          expect(WebMock).to have_requested(:get, /#{stub_url}/).
            with(query: hash_including(url_params)).once
        end
      end

      context 'when field params are a mix of valid and invalid' do
        let(:fields) { described_class::ALLOWED_FIELDS.sample(2) + %w[unrecognized] }
        let(:url_params) { { inc: (fields - %w[unrecognized]).join(',') } }

        it 'performs a request only with the valid params' do
          described_class.fetch_users(fields: fields)

          expect(WebMock).to have_requested(:get, /#{stub_url}/).
            with(query: hash_including(url_params)).once
        end
      end
    end
  end
end
