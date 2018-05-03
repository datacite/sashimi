require 'rails_helper'

describe ReportJob, type: :job do
  include ActiveJob::TestHelper
  let(:report) { create(:report, id: SecureRandom.random_number(9223372036854775807)) }
  subject(:job) { ReportJob.perform_later(report) }

  it 'queues the job' do
    puts report.inspect
    expect { job }.to have_enqueued_job(ReportJob)
      .on_queue("usage")
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
