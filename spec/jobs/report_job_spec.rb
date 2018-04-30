require 'rails_helper'

describe ReportJob, type: :job do
  let(:report) { create(:report) }
  subject(:job) { ReportJob.perform_later(report) }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(ReportJob)
      .on_queue("test_usage")
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
