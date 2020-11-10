# frozen_string_literal: true

class DefendantFinder < ApplicationService
  def initialize(defendant_id:)
    @defendant_id = defendant_id
    @prosecution_case_defendant = ProsecutionCaseDefendantOffence.find_by(defendant_id: defendant_id)
  end

  def call
    cp_defendant
  end

  private

  def cp_defendant
    @cp_defendant ||= cp_prosecution_case&.defendants&.find { |d| d.id.eql?(defendant_id) }
  end

  def cp_prosecution_case
    return unless prosecution_case_urn

    # fetch details needed to include plea and mode of trial reason, at least
    @cp_prosecution_case ||=  Api::SearchProsecutionCase
                              .call(prosecution_case_reference: prosecution_case_urn)
                              &.first
                              &.tap(&:fetch_details)
  end

  def prosecution_case_urn
    @prosecution_case_urn ||= prosecution_case&.body&.fetch('prosecutionCaseReference', nil)
  end

  def prosecution_case
    return unless prosecution_case_defendant&.prosecution_case_id

    @prosecution_case ||= ProsecutionCase.find(prosecution_case_defendant.prosecution_case_id)
  end

  attr_reader :defendant_id, :prosecution_case_defendant, :inclusions
end
