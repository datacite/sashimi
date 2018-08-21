class ReportTypesController < ApplicationController

  # include validation methods for sushi
  include Helpeable

  prepend_before_action :authenticate_user_from_token!
  before_action :set_type, only: [:show, :destroy]


  def index
    # Your code here
    @collection = ReportTypes.all

    render json: @collection, meta: @meta
  end

  def show
    render json: @type
  end


  def create
    @type = ReportTypes.new(safe_params)
    authorize! :create, @type

    if @type.save
      render json: @type, status: :created
    else
      Rails.logger.warn @type.errors.inspect
      render json: @type.errors, status: :unprocessable_entity
    end
  end

  protected

  def set_type
   
    @type = ReportTypes.where(report_id: params[:report_id]).first

    fail ActiveRecord::RecordNotFound unless @type.present?
  end


  def safe_params
    params.require(:report_type).permit(:report_id)
  end

end
