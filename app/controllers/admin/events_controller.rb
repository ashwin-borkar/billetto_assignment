module Admin
  class EventsController < ApplicationController
    def import
      ImportEventsJob.perform_now
      redirect_to root_path, notice: 'Events import started successfully!'
    end
  end
end
