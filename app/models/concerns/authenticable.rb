module Authenticable
  extend ActiveSupport::Concern

  require 'jwt'
  require "base64"

  included do
    # encode JWT token using SHA-256 hash algorithm
    def encode_token(payload)
      return nil if payload.blank?
      
      # replace newline characters with actual newlines
      private_key = OpenSSL::PKey::RSA.new(ENV['JWT_PRIVATE_KEY'].to_s.gsub('\n', "\n"))
      JWT.encode(payload, private_key, 'RS256')
    rescue OpenSSL::PKey::RSAError => e
      Rails.logger.error e.inspect + " for " + payload.inspect

      nil
    end

    # decode JWT token using SHA-256 hash algorithm
    def decode_token(token)
      public_key = OpenSSL::PKey::RSA.new(ENV['JWT_PUBLIC_KEY'].to_s.gsub('\n', "\n"))
      payload = (JWT.decode token, public_key, true, { :algorithm => 'RS256' }).first

      # check whether token has expired
      return {} unless Time.now.to_i < payload["exp"].to_i

      payload
    rescue JWT::DecodeError => error
      Rails.logger.error "JWT::DecodeError: " + error.message + " for " + token
      {}
    rescue OpenSSL::PKey::RSAError => e
      public_key = ENV['JWT_PUBLIC_KEY'].presence || "nil"
      Rails.logger.error "OpenSSL::PKey::RSAError: " + e.message + " for " + public_key
      {}
    end

    # basic auth
    def encode_auth_param(username: nil, password: nil)
      return nil unless username.present? && password.present?

      ::Base64.strict_encode64("#{username}:#{password}")
    end

    # basic auth
    def decode_auth_param(username: nil, password: nil)
      return {} unless username.present? && password.present?

      if username.include?(".")
        user = Client.where(symbol: username.upcase).first
      else
        user = Provider.unscoped.where(symbol: username.upcase).first
      end

      return {} unless user && secure_compare(user.password, encrypt_password_sha256(password))

      uid = username.downcase

      get_payload(uid: uid, user: user)
    end

    def get_payload(uid: nil, user: nil)
      roles = {
        "ROLE_ADMIN" => "staff_admin",
        "ROLE_ALLOCATOR" => "provider_admin",
        "ROLE_DATACENTRE" => "client_admin"
      }
      payload = {
        "uid" => uid,
        "role_id" => roles.fetch(user.role_name, "user"),
        "name" => user.name,
        "email" => user.contact_email
      }

      payload
    end

    # constant-time comparison algorithm to prevent timing attacks
    # from Devise
    def secure_compare(a, b)
      return false if a.blank? || b.blank? || a.bytesize != b.bytesize
      l = a.unpack "C#{a.bytesize}"

      res = 0
      b.each_byte { |byte| res |= byte ^ l.shift }
      res == 0
    end
  end

  module ClassMethods
    # encode token using SHA-256 hash algorithm
    def encode_token(payload)
      # replace newline characters with actual newlines
      private_key = OpenSSL::PKey::RSA.new(ENV['JWT_PRIVATE_KEY'].to_s.gsub('\n', "\n"))
      JWT.encode(payload, private_key, 'RS256')
    rescue OpenSSL::PKey::RSAError => e
      Rails.logger.error e.inspect

      nil
    end

    # basic auth
    def encode_auth_param(username: nil, password: nil)
      return nil unless username.present? && password.present?

      ::Base64.strict_encode64("#{username}:#{password}")
    end

    # generate JWT token
    def generate_token(attributes={})
      payload = {
        uid:  attributes.fetch(:uid, "datacite.datacite"),
        name: attributes.fetch(:name, "staff"),
        email: attributes.fetch(:email, nil),
        provider_id: attributes.fetch(:provider_id, nil),
        client_id: attributes.fetch(:client_id, nil),
        role_id: attributes.fetch(:role_id, "staff_admin"),
        iat: Time.now.to_i,
        exp: Time.now.to_i + attributes.fetch(:exp, 30)
      }.compact

      encode_token(payload)
    end

    def get_payload(uid: nil, user: nil)
      roles = {
        "ROLE_ADMIN" => "staff_admin",
        "ROLE_ALLOCATOR" => "provider_admin",
        "ROLE_DATACENTRE" => "client_admin"
      }
      payload = {
        "uid" => uid,
        "role_id" => roles.fetch(user.role_name, "user"),
        "name" => user.name,
        "email" => user.contact_email
      }

      payload
    end
  end
end
