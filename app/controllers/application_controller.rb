class ApplicationController < ActionController::API
  require 'facets/string/snakecase'

  # include base controller methods
  include Authenticable
  include CanCan::ControllerAdditions

  attr_accessor :current_user

  before_action :default_format_json, :transform_params, :permit_all_params, :set_raven_context
  after_action :set_jsonp_format, :set_consumer_header

  # from https://github.com/spree/spree/blob/master/api/app/controllers/spree/api/base_controller.rb
  def set_jsonp_format
    if params[:callback] && request.get?
      self.response_body = "#{params[:callback]}(#{response.body})"
      headers["Content-Type"] = 'application/javascript'
    end
  end

  def authenticate_user_from_token!
    token = token_from_request_headers
    return false unless token.present?
    raise JWT::VerificationError if (ENV["JWT_BLACKLISTED"] || "").split(",").include?(token)

    @current_user = User.new(token)
  end

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  # from https://github.com/nsarno/knock/blob/master/lib/knock/authenticable.rb
  def token_from_request_headers
    unless request.headers['Authorization'].nil?
      request.headers['Authorization'].split.last
    end
  end

  def set_consumer_header
    if current_user
      response.headers['X-Credential-Username'] = current_user.uid
    else
      response.headers['X-Anonymous-Consumer'] = true
    end
  end

  def default_format_json
    request.format = :json if request.format.html?
  end

  def permit_all_params
    ActionController::Parameters.permit_all_parameters = true
  end

  # convert parameters with hyphen to parameters with underscore.
  #  https://stackoverflow.com/questions/35812277/fields-parameters-with-hyphen-in-ruby-on-rails
  def transform_params
    params.transform_keys! { |key| key.tr('-', '_') }
  end

  rescue_from *RESCUABLE_EXCEPTIONS do |exception|
    status = case exception.class.to_s
              when "CanCan::AccessDenied", "JWT::DecodeError","JWT::VerificationError" then 401
              when "ActiveRecord::RecordNotFound", "AbstractController::ActionNotFound", "ActionController::RoutingError" then 404
              when "ActiveRecord::RecordNotUnique" then 409
              when "ActiveModel::ForbiddenAttributesError", "ActionController::ParameterMissing", "ActionController::UnpermittedParameters", "NoMethodError", "ActiveRecord::RecordInvalid", "JSON::ParserError" then 422
              else 400
              end

      if status == 404
        message = "The resource you are looking for doesn't exist."
      elsif status == 401
        message = "You are not authorized to access this resource."
      elsif status == 406
        message = "The content type is not recognized."
      elsif status == 409
        message = "The resource already exists."
      else
        message = exception.message
      end

    render json: { errors: [{ status: status.to_s, title: message }] }.to_json, status: status
  end

  def set_raven_context
    if current_user.try(:uid)
      Raven.user_context(
        email: current_user.email,
        id: current_user.uid,
        ip_address: request.ip
      )
    else
      Raven.user_context(
        ip_address: request.ip
      )
    end
  end
end
