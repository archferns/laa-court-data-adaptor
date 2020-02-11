# frozen_string_literal: true

module Api
  class ProsecutionCasesController < ApplicationController
    def index
      @prosecution_cases = Api::SearchProsecutionCase.call(transformed_params)

      render json: ProsecutionCaseSerializer.new(@prosecution_cases)
    end

    private

    def filtered_params
      params.require(:filter).permit(:prosecution_case_reference, :arrest_summons_number, :first_name, :last_name, :date_of_birth, :date_of_next_hearing, :national_insurance_number)
    end

    def authenticate; end

    def transformed_params
      filtered_params.to_hash.transform_keys(&:to_sym)
    end
  end
end