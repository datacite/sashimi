# frozen_string_literal: true

module Middleware
  class CompressedRequests
    def initialize(app)
      @app = app
    end

    def method_handled?(env)
      !!(env['REQUEST_METHOD'] =~ /(POST|PUT)/)
    end

    def encoding_handled?(env)
      ['gzip', 'deflate'].include? env['HTTP_CONTENT_ENCODING']
    end

    def call(env)
      request = Rack::Request.new(env)
      if method_handled?(env) && encoding_handled?(env)
        extracted = decode(env['rack.input'], env['HTTP_CONTENT_ENCODING'])
        hsh = JSON.parse(extracted)

        request.update_param('report_header', hsh.fetch("report-header", {}).deep_transform_keys { |key| key.tr('-', '_') })
        request.update_param('compressed', env['rack.input'])
        request.update_param('encoding', env['HTTP_CONTENT_ENCODING'])

        env.delete('HTTP_CONTENT_ENCODING')
        env['CONTENT_LENGTH'] = extracted.length
        env['rack.input'] = StringIO.new(extracted)
      end

      begin
        status, headers, response = @app.call(env)
        [status, headers, response]
      rescue ActionDispatch::Http::MimeNegotiation::InvalidType => error
        Rails.logger.error(err.inspect)
        [406, {}, [{"status": 406, "title": err.message}.to_json]]
      rescue => err
        Raven.capture_exception(err)
        [500, {}, [{"status": 400, "title": err.message}.to_json]]
      end
    end

    def decode(input, content_encoding)
      case content_encoding
      # https://tickets.puppetlabs.com/browse/PUP-7251
      when 'gzip' then Zlib::GzipReader.new(input, encoding: Encoding::BINARY).read
      when 'deflate' then Zlib::Inflate.inflate(input.read)
      end
    end
  end
end
