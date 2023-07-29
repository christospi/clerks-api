require 'rails_helper'

RSpec.describe RandomUserSerializer do
  let(:user) do
    # Parse mocked RandomUser API response to get the first user
    JSON.parse(File.read(Rails.root.join('spec/fixtures/random_user/response.json')))['results'].first
  end

  describe '.to_clerk_attributes' do
    it 'returns a hash with the correct attributes', :aggregate_failures do
      attributes = described_class.to_clerk_attributes(user)

      expect(attributes[:first_name]).to eq(user['name']['first'])
      expect(attributes[:last_name]).to eq(user['name']['last'])
      expect(attributes[:email]).to eq(user['email'])
      expect(attributes[:phone]).to eq(user['phone'])
      expect(attributes[:registration_date]).to eq(DateTime.parse(user['registered']['date']))
      expect(attributes[:picture_url]).to eq(user['picture']['thumbnail'])
    end
  end
end
