require 'cryptoprocessing/client/api_response'
require 'cryptoprocessing/client/api_errors'

module Cryptoprocessing
  # Net-Http response object
  class NetHTTPResponse < APIResponse
    def body
      JSON.parse(@response.body) rescue {}
    end

    def body=(body)
      @response.body = body.to_json
    end

    def data
      body
    end

    def headers
      out = @response.to_hash.map do |key, val|
        [key.upcase.gsub('_', '-'), val.count == 1 ? val.first : val]
      end
      out.to_h
    end

    def status
      @response.code.to_i
    end
  end

  def self.check_response_status(resp)
    if resp.status == 200 && resp.body.kind_of?(Array)
      return
    end

    (resp.body['warnings'] || []).each do |warning|
      message = "WARNING: #{warning['message']}"
      message += " (#{warning['url']})" if warning["url"]
      $stderr.puts message
    end

    # OAuth2 errors
    if resp.status >= 400 && resp.body['error']
      raise Cryptoprocessing::APIError, resp.body['error_description']
    end

    # Regular errors
    if resp.body['errors']
      case resp.status
      when 400
        case resp.body['errors'].first['id']
        when 'param_required' then
          raise ParamRequiredError, format_error(resp)
        when 'invalid_request' then
          raise InvalidRequestError, format_error(resp)
        when 'personal_details_required' then
          raise PersonalDetailsRequiredError, format_error(resp)
        end
        raise BadRequestError, format_error(resp)
      when 401
        case resp.body['errors'].first['id']
        when 'authentication_error' then
          raise AuthenticationError, format_error(resp)
        when 'unverified_email' then
          raise UnverifiedEmailError, format_error(resp)
        when 'invalid_token' then
          raise InvalidTokenError, format_error(resp)
        when 'revoked_token' then
          raise RevokedTokenError, format_error(resp)
        when 'expired_token' then
          raise ExpiredTokenError, format_error(resp)
        end
        raise AuthenticationError, format_error(resp)
      when 402 then
        raise TwoFactorRequiredError, format_error(resp)
      when 403 then
        raise InvalidScopeError, format_error(resp)
      when 404 then
        raise NotFoundError, format_error(resp)
      when 422 then
        raise ValidationError, format_error(resp)
      when 429 then
        raise RateLimitError, format_error(resp)
      when 500 then
        raise InternalServerError, format_error(resp)
      when 503 then
        raise ServiceUnavailableError, format_error(resp)
      end
    end

    # API errors
    if resp.body['status'] == 'fail'
      raise Cryptoprocessing::APIError, resp.body['message']
    end

    if resp.status > 400
      raise Cryptoprocessing::APIError, "[#{resp.status}] #{resp.body}"
    end
  end
end