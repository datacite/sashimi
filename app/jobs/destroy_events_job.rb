class DestroyEventsJob < ActiveJob::Base
  queue_as :sashimi

  def perform(id, options={})
    Report.destroy_events(id)
  end
end
