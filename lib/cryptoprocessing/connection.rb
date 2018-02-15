require 'net/http'
require 'json/ext'
require 'cryptoprocessing/version'
require 'cryptoprocessing/client/net_response'

module Cryptoprocessing
  module Connection

    def endpoint
      api_endpoint
    end

    # @return [Net::HTTP]
    def agent
      base_uri = URI.parse(endpoint)
      @agent = Net::HTTP.new(base_uri.host, base_uri.port)
      @agent.use_ssl = true if base_uri.scheme == 'https'
      # @agent.cert_store = self.class.whitelisted_certificates
      @agent.ssl_version = :TLSv1
      @agent
    end

    ##
    # @param [String] method
    # @param [String] path
    # @param [String] body
    # @param [String] headers
    def request(method, path, body = nil, headers = {})
      # Prepend configured namespace
      path = "#{@api_namespace}#{path}"

      case method
      when 'GET' then
        req = Net::HTTP::Get.new(path)
      when 'PUT' then
        req = Net::HTTP::Put.new(path)
      when 'POST' then
        req = Net::HTTP::Post.new(path)
      when 'DELETE' then
        req = Net::HTTP::Delete.new(path)
      else
        raise
      end

      req.body = body

      # All requests with JSON encoded body
      req['Content-Type'] = 'application/json'

      # Set User Agent to Gem name and version
      req['User-Agent'] = user_agent

      auth_headers(method, path, body).each do |key, val|
        req[key] = val
      end
      headers.each do |key, val|
        req[key] = val
      end

      resp = agent.request(req)
      out = Cryptoprocessing::NetHTTPResponse.new(resp)
      Cryptoprocessing::check_response_status(out)
      yield(out) if block_given?
      out.data
    end

    def auth_headers(method, path, body)
      {:Authorization => "Bearer #{@access_token}"}
    end

    def reset_agent
      @agent = nil
    end

    ##
    # HTTP GET method
    #
    # @param [String] path
    def get(path, params = {})
      uri = path
      if params.count > 0
        uri += "?#{URI.encode_www_form(params)}"
      end

      headers = {}

      request('GET', uri, nil, headers) do |resp|
        if params[:fetch_all] == true &&
            resp.body.has_key?('pagination') &&
            resp.body['pagination']['next_uri'] != nil
          params[:starting_after] = resp.body['data'].last['id']
          get(path, params) do |page|
            body = resp.body
            body['data'] += page.data
            resp.body = body
            yield(resp) if block_given?
          end
        else
          yield(resp) if block_given?
        end
      end
    end

    ##
    # HTTP PUT method
    #
    # @param [String] path
    def put(path, params)
      headers = {}

      request('PUT', path, params.to_json, headers) do |resp|
        yield(resp) if block_given?
      end
    end

    ##
    # HTTP POST method
    #
    # @param [String] path
    def post(path, params)
      headers = {}

      request('POST', path, params.to_json, headers) do |resp|
        yield(resp) if block_given?
      end
    end

    ##
    # HTTP DELETE method
    #
    # @param [String] path
    def delete(path, params)
      headers = {}

      request('DELETE', path, nil, headers) do |resp|
        yield(resp) if block_given?
      end
    end
  end
end