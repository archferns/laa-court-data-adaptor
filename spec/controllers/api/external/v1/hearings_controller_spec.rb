# frozen_string_literal: true

RSpec.describe Api::External::V1::HearingsController, type: :controller do
  include AuthorisedRequestHelper

  before { authorise_requests! }

  let(:valid_attributes) { JSON.parse(file_fixture("valid_hearing.json").read) }
  let(:invalid_attributes) { JSON.parse(file_fixture("invalid_hearing.json").read) }
  let(:unprocessable_attributes) { JSON.parse(file_fixture("unprocessable_hearing.json").read) }

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Hearing" do
        expect {
          post :create, params: valid_attributes, as: :json
        }.to change(Hearing, :count).by(1)
      end

      it "renders a JSON response with an empty response" do
        post :create, params: valid_attributes, as: :json
        expect(response.body).to be_empty
        expect(response).to have_http_status(:accepted)
      end
    end

    context "with an invalid hearing" do
      it "renders a JSON response with an unprocessable_entity error" do
        allow(HearingRecorder).to receive(:call).and_return(Hearing.new)
        post :create, params: unprocessable_attributes, as: :json
        expect(response.body).to include("must be an integer")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new hearing" do
        post :create, params: invalid_attributes, as: :json
        expect(response.body).to include("param is missing or the value is empty")
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
