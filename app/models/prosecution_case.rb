# frozen_string_literal: true

class ProsecutionCase < ApplicationRecord
  validates :body, presence: true

  def defendants
    body['defendantSummary'].map { |defendant| Defendant.new(body: defendant, details: defendant_details.dig(defendant['defendantId'])) }
  end

  def defendant_ids
    defendants.map(&:id)
  end

  def hearing_summaries
    body.dig('hearingSummary')&.map { |hearing_summary| HearingSummary.new(body: hearing_summary) } || []
  end

  def hearing_summary_ids
    hearing_summaries.map(&:id)
  end

  def hearings
    hearing_results.select(&:body)
  end

  def hearing_ids
    hearings.map(&:id)
  end

  def prosecution_case_reference
    body['prosecutionCaseReference']
  end

  private

  def case_details
    hearings.flat_map do |hearing|
      hearing.body['prosecutionCases'].select { |prosecution_case| prosecution_case['id'] == id }
    end
  end

  def hearings_fetched?
    @hearing_results.present?
  end

  def defendant_details
    return {} unless hearings_fetched?

    case_details.flat_map { |detail| detail['defendants'] }.map { |detail| [detail['id'], detail] }.to_h
  end

  def hearing_results
    @hearing_results ||= hearing_summary_ids.map do |hearing_id|
      Api::GetHearingResults.call(hearing_id: hearing_id)
    end
  end
end
