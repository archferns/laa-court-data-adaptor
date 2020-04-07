# frozen_string_literal: true

RSpec.describe Api::RecordRepresentationOrder do
  subject { described_class.call(params) }

  let(:prosecution_case_id) { 'b9950946-fe3b-4eaa-9f0a-35e497e34528' }
  let(:defendant_id) { '23d7f10a-067a-476e-bba6-bb855674e23b' }
  let(:offence_id) { '147fed98-ba8a-46cb-b2b4-7c41cf4734bf' }
  let(:defence_organisation) do
    {
      'organisation' => {
        'name' => 'SOME ORGANISATION'
      },
      'laaContractNumber' => 'CONTRACT REFERENCE'
    }
  end

  let(:params) do
    {
      prosecution_case_id: prosecution_case_id,
      defendant_id: defendant_id,
      offence_id: offence_id,
      status_code: 'ABCDEF',
      application_reference: 'SOME SORT OF MAAT ID',
      status_date: '2019-12-12',
      effective_start_date: '2019-12-15',
      effective_end_date: '2020-12-15',
      defence_organisation: defence_organisation
    }
  end

  # rubocop:disable Layout/LineLength
  let(:url) { "/receive/representation/progression-command-api/command/api/rest/progression/representationOrder/cases/#{prosecution_case_id}/defendants/#{defendant_id}/offences/#{offence_id}" }
  # rubocop:enable Layout/LineLength

  let!(:case_defendant_offence) do
    ProsecutionCaseDefendantOffence.create!(prosecution_case_id: prosecution_case_id,
                                            defendant_id: defendant_id,
                                            offence_id: offence_id)
  end

  it 'returns a no content status' do
    VCR.use_cassette('representation_order_recorder/update') do
      expect(subject.status).to eq(204)
    end
  end

  context 'connection' do
    let(:connection) { double('CommonPlatformConnection') }
    let(:headers) { { 'Ocp-Apim-Subscription-Key' => 'SECRET KEY' } }
    let(:request_params) do
      {
        statusCode: 'ABCDEF',
        applicationReference: 'SOME SORT OF MAAT ID',
        statusDate: '2019-12-12',
        effectiveStartDate: '2019-12-15',
        effectiveEndDate: '2020-12-15',
        defenceOrganisation: defence_organisation
      }
    end

    before do
      allow(connection).to receive(:post).and_return(Faraday::Response.new(status: 200, body: { 'test' => 'test' }))
      params.merge!(shared_key: 'SECRET KEY', connection: connection)
    end

    it 'makes a post request' do
      expect(connection).to receive(:post).with(url, request_params, headers)
      subject
    end

    it 'updates the database record for the offence' do
      subject
      case_defendant_offence.reload
      expect(case_defendant_offence.status_date).to eq '2019-12-12'
      expect(case_defendant_offence.effective_start_date).to eq '2019-12-15'
      expect(case_defendant_offence.effective_end_date).to eq '2020-12-15'
      expect(case_defendant_offence.defence_organisation).to eq defence_organisation
      expect(case_defendant_offence.rep_order_status).to eq 'ABCDEF'
      expect(case_defendant_offence.response_status).to eq(200)
      expect(case_defendant_offence.response_body).to eq({ 'test' => 'test' })
    end

    context 'without an effective_end_date' do
      before do
        params.delete(:effective_end_date)
      end

      let(:request_params) do
        {
          statusCode: 'ABCDEF',
          applicationReference: 'SOME SORT OF MAAT ID',
          statusDate: '2019-12-12',
          effectiveStartDate: '2019-12-15',
          defenceOrganisation: defence_organisation
        }
      end

      it 'posts successfully without the effectiveEndDate' do
        expect(connection).to receive(:post).with(url, request_params, headers)
        subject
      end
    end
  end
end
