# frozen_string_literal: true

RSpec.describe Defendant, type: :model do
  let(:defendant_hash) do
    {
      'name' => {
        'firstName' => 'Alfredine',
        'lastName' => 'Parker'
      },
      'dateOfBirth' => '1971-05-12',
      'nationalInsuranceNumber' => 'BN102966C',
      'arrestSummonsNumber' => 'ARREST123'
    }
  end

  subject(:defendant) { described_class.new(body: defendant_hash) }

  it { expect(defendant.first_name).to eq('Alfredine') }
  it { expect(defendant.last_name).to eq('Parker') }
  it { expect(defendant.date_of_birth).to eq('1971-05-12') }
  it { expect(defendant.national_insurance_number).to eq('BN102966C') }
  it { expect(defendant.arrest_summons_number).to eq('ARREST123') }
end
