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
end
