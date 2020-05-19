# frozen_string_literal: true

class ErrorsController < ApplicationController

  def not_found
    respond_to do |format|
      format.html { render "errors/not_found", status: :not_found }
      format.all { render nothing: true, status: :not_found }
    end
  end
end
