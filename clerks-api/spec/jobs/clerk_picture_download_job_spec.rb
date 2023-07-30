require 'rails_helper'

RSpec.describe ClerkPictureDownloadJob, type: :job do
  let(:clerk) do
    Clerk.create!(
      first_name: 'Down',
      last_name: 'Loader',
      email: 'down@loader.com',
      phone: '1234567890',
      registration_date: 1.day.ago
    )
  end
  let(:picture_url) { 'https://example.com/picture.jpg' }
  let(:picture_file) { File.open('spec/fixtures/files/picture.jpg') }

  before do
    allow(Downloader).to receive(:download).and_return(picture_file)
  end

  it 'downloads and attaches the picture' do
    expect {
      described_class.perform_now(clerk.id, picture_url)
      clerk.reload
    }.to change { clerk.picture.attached? }.from(false).to(true)
  end

  it 'calls Downloader.download with the correct URL' do
    described_class.perform_now(clerk.id, picture_url)
    expect(Downloader).to have_received(:download).with(picture_url)
  end
end
