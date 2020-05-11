# frozen_string_literal: true

class HearingEventsFetcher < ApplicationService
  URL = '/LAAGetHearingLogHttpTrigger'

  def initialize(hearing_id:, shared_key: ENV['SHARED_SECRET_KEY_HEARING'], connection: CommonPlatformConnection.call)
    @params = { hearingId: hearing_id }
    @headers = { 'Ocp-Apim-Subscription-Key' => shared_key }
    @connection = connection
  end

  def call
    connection.get(URL, params, headers)
  end

  private

  attr_reader :params, :headers, :connection
end