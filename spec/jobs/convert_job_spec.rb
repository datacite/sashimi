require 'rails_helper'

describe ConvertJob, type: :job do
  let(:bigly) { file_fixture('DSR-D1-2012-07-10.json').read }
  let(:gzipped) { ActiveSupport::Gzip.compress(bigly) }
  let(:compressed_report) { create(:report_subset, compressed: gzipped) }
  subject(:job) { ConvertJob.perform_later(compressed_report.id) }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(ConvertJob)
      .on_queue("test_sashimi").at_least(1).times
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
