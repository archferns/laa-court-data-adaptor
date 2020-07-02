# frozen_string_literal: true

class Hearing < ApplicationRecord
  validates :body, presence: true

  def court_name
    hearing_body['courtCentre']['name']
  end

  def hearing_type
    hearing_body['type']['description']
  end

  def defendant_names
    defendants.map do |defendant|
      "#{defendant['personDefendant']['personDetails']['firstName']} #{defendant['personDefendant']['personDetails']['lastName']}"
    end
  end

  def hearing_events
    hearing_day_events.map { |hearing_day_event| HearingEvent.new(body: hearing_day_event) }
  end

  def hearing_event_ids
    hearing_events.map(&:id)
  end

  def judge_names
    judiciary.map do |judge|
      "#{judge['title']} #{judge['firstName']} #{judge['middleName']} #{judge['lastName']}"
    end
  end

  def prosecution_advocate_names
    hearing_body.dig('prosecutionCounsels')&.map do |prosecution_counsel|
      "#{prosecution_counsel['firstName']} #{prosecution_counsel['lastName']}"
    end
  end

  def defence_advocate_names
    defence_details = hearing_body['defenceCounsels']
    defence_details.map do |detail|
      "#{detail['firstName']} #{detail['lastName']}"
    end
  end

  private

  def hearing_body
    body['hearing']
  end

  def prosecution_cases
    hearing_body['prosecutionCases']
  end

  def defendants
    prosecution_cases.flat_map { |prosecution_case| prosecution_case['defendants'] }
  end

  def hearing_event_recordings
    @hearing_event_recordings ||= hearing_body['hearingDays'].flat_map do |hearing_day|
      Api::GetHearingEvents.call(hearing_id: id, hearing_date: hearing_day['sittingDay'].to_date)
    end
  end

  def hearing_day_events
    hearing_event_recordings.flat_map { |recording| recording.body['events'] }
  end

  def judiciary
    hearing_body['hearingDays'].flat_map { |hearing_day| hearing_day['onTheDayJudiciary'] }.compact
  end
end
