require 'rails_helper'

describe ValidationJob, type: :job do
  include ActiveJob::TestHelper

  let(:compresed_report) { create(:report) }
  subject(:job) { ValidationJob.perform_later(compresed_report) }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(ValidationJob)
      .on_queue("test_sashimi")
  end

  it 'execute further call' do
    response = perform_enqueued_jobs do
      ValidationJob.new.perform(compresed_report)
    end
    expect(response).not_to be_a(Hash)
  end

  # after do
  #   clear_enqueued_jobs
  #   clear_performed_jobs
  # end
end