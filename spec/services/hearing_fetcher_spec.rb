# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HearingFetcher do
  subject { described_class.call(hearing_id: hearing_id) }

  let(:hearing_id) { 'ab746921-d839-4867-bcf9-b41db8ebc852' }

  it 'returns the requested hearing info' do
    VCR.use_cassette('hearing_result_fetcher/success') do
      expect(subject.body['hearing']['id']).to eq(hearing_id)
    end
  end

  context 'with a incorrect key' do
    subject { described_class.call(hearing_id: hearing_id, shared_key: 'INCORRECT KEY') }

    it 'returns a not found response' do
      VCR.use_cassette('hearing_result_fetcher/unauthorised') do
        expect(subject.status).to eq(401)
      end
    end
  end
end
