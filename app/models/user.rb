class User
  # include jwt encode and decode
  include Authenticable

  attr_accessor :name, :uid, :email, :role_id, :jwt, :provider_id, :client_id

  def initialize(token)
    if token.present?
      payload = decode_token(token)

      @jwt = token
      @uid = payload.fetch("uid", nil)
      @name = payload.fetch("name", nil)
      @email = payload.fetch("email", nil)
      @role_id = payload.fetch("role_id", nil)
      @provider_id = payload.fetch("provider_id", nil)
      @client_id = payload.fetch("client_id", nil)
    else
      @role_id = "anonymous"
    end
  end

  alias_method :id, :uid

  # Helper method to check for admin user
  def is_admin?
    role_id == "staff_admin"
  end
end
