require 'rails_helper'

describe ValidationJob, type: :job do
  include ActiveJob::TestHelper

  context "good metadata" do
    let(:bigly) {file_fixture('small_dataone.json').read}
    # let(:report) {create(:report)}
    # let(:report_id) {report.uid}

    let(:gzipped) do
      ActiveSupport::Gzip.compress(bigly)
    end    

    let(:compresed_report) { create(:report_subset, compressed: gzipped) }

    # subject(:job) { ValidationJob.perform_later(gzipped, {report_id: report_id}) }
    subject(:job) { ValidationJob.perform_later(compresed_report.id) }

    it 'queues the job' do
      # expect { job }.to have_enqueued_job(ValidationJob)
      #   .on_queue("test_sashimi")
    end

    it 'execute further call' do
      response = perform_enqueued_jobs do
        # ValidationJob.new.perform(gzipped, {report_id: report_id})
        ValidationJob.new.perform(compresed_report.id)
      end
      expect(response).not_to be_a(Array)
    end

    # after do
    #   clear_enqueued_jobs
    #   clear_performed_jobs
    # end
  end

  context "bad metadata" do
    let(:bigly) {file_fixture('DSR-D1-2012-07-10.json').read}
    # let(:report) {create(:report)}
    # let(:report_id) {report.uid}

    let(:gzipped) do
      ActiveSupport::Gzip.compress(bigly)
    end    

    let(:compresed_report) { create(:report_subset, compressed: gzipped) }

    subject(:job) { ValidationJob.perform_later(compresed_report.id) }
    # subject(:job) { ValidationJob.perform_later(gzipped, {report_id: report_id}) }

    it 'queues the job' do
      # expect { job }.to have_enqueued_job(ValidationJob)
      #   .on_queue("test_sashimi")
    end

    it 'execute further call' do
      response = perform_enqueued_jobs do
        # ValidationJob.new.perform(gzipped, {report_id: report_id})
        ValidationJob.new.perform(compresed_report.id)
      end
      expect(response).to be_a(Array)
    end

    # after do
    #   clear_enqueued_jobs
    #   clear_performed_jobs
    # end
  end
end