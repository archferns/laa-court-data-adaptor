# frozen_string_literal: true

module Api
  class RecordLaaReference < ApplicationService
    def initialize(prosecution_case_defendant_offence:,
                   status_code:,
                   application_reference:,
                   status_date:,
                   shared_key: ENV['SHARED_SECRET_KEY_LAA_REFERENCE'],
                   connection: CommonPlatformConnection.call)

      @prosecution_case_defendant_offence = prosecution_case_defendant_offence
      @status_code = status_code
      @application_reference = application_reference
      @status_date = status_date
      @response = connection.post(url, request_body, { 'Ocp-Apim-Subscription-Key' => shared_key })
    end

    def call
      update_database
    end

    private

    def request_body
      {
        statusCode: status_code,
        applicationReference: application_reference,
        statusDate: status_date
      }
    end

    def update_database
      prosecution_case_defendant_offence.maat_reference = application_reference
      prosecution_case_defendant_offence.dummy_maat_reference = dummy_maat_reference
      prosecution_case_defendant_offence.rep_order_status = status_code
      prosecution_case_defendant_offence.status_date = status_date
      prosecution_case_defendant_offence.response_status = response.status
      prosecution_case_defendant_offence.response_body = response.body
      prosecution_case_defendant_offence.save!
    end

    def dummy_maat_reference
      (%w[A Z].include? application_reference.to_s[0])
    end

    def url
      @url ||= '/record/laareference/progression-command-api'\
              '/command/api/rest/progression/laaReference'\
              "/cases/#{prosecution_case_defendant_offence.prosecution_case_id}"\
              "/defendants/#{prosecution_case_defendant_offence.defendant_id}"\
              "/offences/#{prosecution_case_defendant_offence.offence_id}"
    end

    attr_reader :prosecution_case_defendant_offence, :status_code, :application_reference, :status_date, :response
  end
end
