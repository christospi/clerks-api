require 'rails_helper'

# TODO: Add some tests for picture validations
# TODO: Add FactoryBot to generate test data

RSpec.describe Clerk, type: :model do
  let(:valid_params) do
    {
      first_name: 'Christos',
      last_name: 'Sotsirhc',
      email: 'chris@domain.com',
      phone: '+6900000000',
      registration_date: Time.zone.now
    }
  end

  it 'is valid with valid attributes' do
    clerk = described_class.new(valid_params)

    expect(clerk).to be_valid
  end

  it 'is not valid without a first_name' do
    clerk = described_class.new(valid_params.merge(first_name: nil))

    expect(clerk).not_to be_valid
  end

  it 'is not valid without a last_name' do
    clerk = described_class.new(valid_params.merge(last_name: nil))

    expect(clerk).not_to be_valid
  end

  it 'is not valid without an email' do
    clerk = described_class.new(valid_params.merge(email: nil))

    expect(clerk).not_to be_valid
  end

  it 'is not valid with a duplicate email' do
    described_class.create(valid_params)
    clerk = described_class.new(
      first_name: 'Another',
      last_name: 'Clerk',
      email: valid_params[:email].upcase,
      phone: '+6900000000',
      registration_date: Time.zone.now
    )

    expect(clerk).not_to be_valid
  end

  it 'is not valid with an email longer than 128 characters' do
    long_email = "#{'a' * 118}@domain.com"
    clerk = described_class.new(valid_params.merge(email: long_email))

    expect(clerk).not_to be_valid
  end

  it 'is not valid without a phone' do
    clerk = described_class.new(valid_params.merge(phone: nil))

    expect(clerk).not_to be_valid
  end

  it 'is not valid with a phone longer than 32 characters' do
    long_phone = '1' * 33
    clerk = described_class.new(valid_params.merge(phone: long_phone))

    expect(clerk).not_to be_valid
  end

  it 'is not valid without a registration_date' do
    clerk = described_class.new(valid_params.merge(registration_date: nil))

    expect(clerk).not_to be_valid
  end

  describe '.create_from_random_user' do
    let(:random_user_response) do
      Array.wrap(JSON.parse(File.read(Rails.root.join('spec/fixtures/random_user/response.json')))['results'].first)
    end
    let(:user) { random_user_response.first }

    before do
      allow(RandomUser).to receive(:fetch_users).and_return(random_user_response)

      picture_file = File.open(Rails.root.join('spec/fixtures/files/picture.jpg'))
      allow(Downloader).to receive(:download).and_return(picture_file)
    end

    it 'creates a new Clerk record', :aggregate_failures do
      expect { described_class.create_from_random_user }.to change(described_class, :count).by(1)
      clerk = described_class.first

      expect(clerk.first_name).to eq(user['name']['first'])
      expect(clerk.last_name).to eq(user['name']['last'])
      expect(clerk.email).to eq(user['email'])
      expect(clerk.phone).to eq(user['phone'])
      expect(clerk.registration_date).to eq(DateTime.parse(user['registered']['date']))
      expect(clerk.picture).to be_attached
    end
  end
end
