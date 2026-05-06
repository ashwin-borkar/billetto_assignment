class ApiController < ApplicationController
  private

  def command_bus
    Rails.application.command_bus
  end
end
