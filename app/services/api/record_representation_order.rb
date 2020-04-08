# frozen_string_literal: true

module Api
  class RecordRepresentationOrder < ApplicationService
    # rubocop:disable Metrics/ParameterLists
    def initialize(prosecution_case_defendant_offence:,
                   status_code:,
                   application_reference:,
                   status_date:,
                   effective_start_date:,
                   effective_end_date: nil,
                   defence_organisation:,
                   shared_key: ENV['SHARED_SECRET_KEY_REPRESENTATION_ORDER'],
                   connection: CommonPlatformConnection.call)

      @prosecution_case_defendant_offence = prosecution_case_defendant_offence
      @status_code = status_code
      @application_reference = application_reference
      @status_date = status_date
      @effective_start_date = effective_start_date
      @effective_end_date = effective_end_date
      @defence_organisation = defence_organisation
      @response = connection.post(url, request_body, { 'Ocp-Apim-Subscription-Key' => shared_key })
    end
    # rubocop:enable Metrics/ParameterLists

    def call
      update_database
    end

    private

    def request_body
      {
        statusCode: status_code,
        applicationReference: application_reference,
        statusDate: status_date,
        effectiveStartDate: effective_start_date,
        effectiveEndDate: effective_end_date,
        defenceOrganisation: defence_organisation
      }.compact
    end

    def update_database
      prosecution_case_defendant_offence.rep_order_status = status_code
      prosecution_case_defendant_offence.status_date = status_date
      prosecution_case_defendant_offence.effective_start_date = effective_start_date
      prosecution_case_defendant_offence.effective_end_date = effective_end_date
      prosecution_case_defendant_offence.defence_organisation = defence_organisation
      prosecution_case_defendant_offence.response_status = response.status
      prosecution_case_defendant_offence.response_body = response.body
      prosecution_case_defendant_offence.save!
    end

    def url
      @url ||= '/receive/representation/progression-command-api'\
              '/command/api/rest/progression/representationOrder' \
              "/cases/#{prosecution_case_defendant_offence.prosecution_case_id}" \
              "/defendants/#{prosecution_case_defendant_offence.defendant_id}" \
              "/offences/#{prosecution_case_defendant_offence.offence_id}"
    end

    attr_reader :prosecution_case_defendant_offence,
                :status_code,
                :application_reference,
                :status_date,
                :effective_start_date,
                :effective_end_date,
                :defence_organisation,
                :response
  end
end
