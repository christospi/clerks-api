require 'rails_helper'

RSpec.describe 'Clerks', type: :request do
  describe 'GET /index' do
    # TODO: FactoryBot I miss you :(
    def generate_clerk_attributes(index)
      {
        first_name: "First Name #{index}",
        last_name: "Last Name #{index}",
        email: "email#{index}@example.com",
        phone: (index.to_s * 10),
        registration_date: index.days.ago
      }
    end

    let!(:clerks) do
      (1..3).map do |index|
        Clerk.create!(generate_clerk_attributes(index))
      end
    end

    it 'returns http success' do
      get '/clerks'

      expect(response).to have_http_status(:success)
    end

    context 'when no search params are provided' do
      it 'returns all clerks' do
        get '/clerks'

        expect(assigns(:clerks)).to match_array(clerks)
      end
    end

    context 'with ending_before param' do
      it 'returns clerks with registration_date and id less than the given clerk' do
        get '/clerks', params: { ending_before: clerks[2].id }
        expect(assigns(:clerks)).to match_array(clerks[0..1])
      end

      it 'returns no clerks if the given clerk does not exist' do
        get '/clerks', params: { ending_before: 0 }
        expect(assigns(:clerks)).to be_empty
      end
    end

    context 'with starting_after param' do
      it 'returns clerks with registration_date and id greater than the given clerk' do
        get '/clerks', params: { starting_after: clerks[0].id }
        expect(assigns(:clerks)).to match_array(clerks[1..2])
      end

      it 'returns no clerks if the given clerk does not exist' do
        get '/clerks', params: { starting_after: 0 }
        expect(assigns(:clerks)).to be_empty
      end
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
