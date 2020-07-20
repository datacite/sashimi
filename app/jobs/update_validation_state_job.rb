require "benchmark"

class UpdateValidationStateJob < ActiveJob::Base
  queue_as :sashimi

  def perform(id, _options = {})
    report = Report.find(id: id)
    report.update_state
  end
end
