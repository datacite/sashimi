class ReportSubsetsController < ApplicationController

  # include validation methods for sushi
  include Helpeable

  prepend_before_action :authenticate_user_from_token!
  before_action :set_report_subset, only: [:show]

  def show
    render json: @report_subset, serializer: ReportFullSubsetSerializer, report_header: @report_header, gzip: @subset['gzip']
  end

  def set_report_subset
    @report_subset = ReportSubset.where(id: params[:id]).first
    fail ActiveRecord::RecordNotFound unless @report_subset.present?

    report = Report.where(uid: @report_subset.report_id).first
    fail ActiveRecord::RecordNotFound unless report.present?

    attachment = AttachmentParser.new(report.load_attachment)
    @subset = attachment.find_subset(@report_subset.checksum)
    @report_header = attachment.header
  end
end
