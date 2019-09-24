require 'rails_helper'

describe ValidationJob, type: :job do
  include ActiveJob::TestHelper

  context "good metadata" do
    let(:bigly) {file_fixture('small_dataone.json').read}
    let(:gzipped) { ActiveSupport::Gzip.compress(bigly) }
    let(:compressed_report) { create(:report_subset, compressed: gzipped) }

    subject(:job) { ValidationJob.perform_later(compressed_report.id) }

    it 'queues the job' do
      expect { job }.to have_enqueued_job(ValidationJob)
        .on_queue("test_sashimi").at_least(1).times
    end

    it 'execute further call' do
      response = perform_enqueued_jobs do
        ValidationJob.new.perform(compressed_report.id)
      end
      expect(response).to be true
    end

    after do
      clear_enqueued_jobs
      clear_performed_jobs
    end
  end

  context "bad metadata" do
    let(:bigly) {file_fixture('DSR-D1-2012-07-10.json').read}
    let(:gzipped) { ActiveSupport::Gzip.compress(bigly) }
    let(:compressed_report) { create(:report_subset, compressed: gzipped) }

    subject(:job) { ValidationJob.perform_later(compressed_report.id) }

    it 'queues the job' do
      expect { job }.to have_enqueued_job(ValidationJob)
        .on_queue("test_sashimi").at_least(1).times
    end

    it 'execute further call' do
      response = perform_enqueued_jobs do
        ValidationJob.new.perform(compressed_report.id)
      end
      expect(response).to be false
    end

    after do
      clear_enqueued_jobs
      clear_performed_jobs
    end
  end
end
