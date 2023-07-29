require 'rails_helper'

RSpec.describe 'Clerks', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/clerks'

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /populate' do
    let(:random_user_response) do
      Array.wrap(JSON.parse(File.read(Rails.root.join('spec/fixtures/random_user/response.json')))['results'].first)
    end

    before do
      allow(RandomUser).to receive(:fetch_users).and_return(random_user_response)

      picture_file = File.open(Rails.root.join('spec/fixtures/files/picture.jpg'))
      allow(Downloader).to receive(:download).and_return(picture_file)
    end

    it 'creates new Clerk records' do
      expect { post '/populate' }.to change(Clerk, :count).by(1)
    end

    it 'redirects to the clerks index page' do
      post '/populate'

      expect(response).to redirect_to(clerks_path)
    end
  end
end
