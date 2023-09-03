class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordInvalid,   with: -> { head :unprocessable_entity }
  rescue_from ActiveRecord::RecordNotUnique, with: -> { head :unprocessable_entity }
end
