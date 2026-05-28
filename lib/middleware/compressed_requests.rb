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
        raw_body = env['rack.input'].read
        extracted = decode(raw_body, env['HTTP_CONTENT_ENCODING'])
        hsh = JSON.parse(extracted)

        env['sashimi.compressed_payload'] = raw_body
        env['sashimi.request_encoding'] = env['HTTP_CONTENT_ENCODING']

        request.update_param('report_header', hsh.fetch("report-header", {}).deep_transform_keys { |key| key.tr('-', '_') })
        request.update_param('compressed', StringIO.new(raw_body))
        request.update_param('encoding', env['HTTP_CONTENT_ENCODING'])

        env.delete('HTTP_CONTENT_ENCODING')
        env['CONTENT_LENGTH'] = extracted.bytesize.to_s
        env['rack.input'] = StringIO.new(extracted)
      end

      begin
        status, headers, response = @app.call(env)
        [status, headers, response]
      rescue ActionDispatch::Http::MimeNegotiation::InvalidType => error
        Rails.logger.error(error.inspect)
        [406, {}, [{"status": 406, "title": error.message}.to_json]]
      rescue => err
        Sentry.capture_exception(err)
        [500, {}, [{"status": 400, "title": err.message}.to_json]]
      end
    end

    def decode(input, content_encoding)
      case content_encoding
      # https://tickets.puppetlabs.com/browse/PUP-7251
      when 'gzip' then Zlib::GzipReader.new(StringIO.new(input), encoding: Encoding::BINARY).read
      when 'deflate' then Zlib::Inflate.inflate(input)
      end
    end
  end
end
