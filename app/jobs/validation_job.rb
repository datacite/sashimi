require "benchmark"

class ValidationJob < ActiveJob::Base
  queue_as :sashimi

  def perform(id, options = {})
    subset = ReportSubset.find(id)
    subset.validate_compressed(options)
  end
end
