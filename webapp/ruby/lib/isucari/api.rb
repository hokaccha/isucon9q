require 'json'
require 'uri'
require 'net/http'
require 'typhoeus'

module Isucari
  class API
    class Error < StandardError; end

    ISUCARI_API_TOKEN = 'Bearer 75ugk2m37a750fwir5xr-22l6h4wmue1bwrubzwd0'

    def initialize
      @user_agent = 'isucon9-qualify-webapp'
    end

    def payment_token(payment_url, param)
      uri = URI.parse("#{payment_url}/token")

      req = Net::HTTP::Post.new(uri.path)
      req.body = param.to_json
      req['Content-Type'] = 'application/json'
      req['User-Agent'] = @user_agent

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      res = http.start { http.request(req) }

      if res.code != '200'
        raise Error, "status code #{res.code}; body #{res.body}"
      end

      JSON.parse(res.body)
    end

    def shipment_create(shipment_url, param)
      uri = URI.parse("#{shipment_url}/create")

      req = Net::HTTP::Post.new(uri.path)
      req.body = param.to_json
      req['Content-Type'] = 'application/json'
      req['User-Agent'] = @user_agent
      req['Authorization'] = ISUCARI_API_TOKEN

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      res = http.start { http.request(req) }

      if res.code != '200'
        raise Error, "status code #{res.code}; body #{res.body}"
      end

      JSON.parse(res.body)
    end

    def shipment_request(shipment_url, param)
      uri = URI.parse("#{shipment_url}/request")

      req = Net::HTTP::Post.new(uri.path)
      req.body = param.to_json
      req['Content-Type'] = 'application/json'
      req['User-Agent'] = @user_agent
      req['Authorization'] = ISUCARI_API_TOKEN

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      res = http.start { http.request(req) }

      if res.code != '200'
        raise Error, "status code #{res.code}; body #{res.body}"
      end

      res.body
    end

    def shipment_status(shipment_url, param)
      uri = URI.parse("#{shipment_url}/status")

      req = Net::HTTP::Post.new(uri.path)
      req.body = param.to_json
      req['Content-Type'] = 'application/json'
      req['User-Agent'] = @user_agent
      req['Authorization'] = ISUCARI_API_TOKEN

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      res = http.start { http.request(req) }

      if res.code != '200'
        raise Error, "status code #{res.code}; body #{res.body}"
      end

      JSON.parse(res.body)
    end

    def shipment_status_parallel(shipment_url, reserve_ids)
      uri = URI.parse("#{shipment_url}/status")
      hydra = Typhoeus::Hydra.hydra
      results = {}
      reserve_ids.each do |rid|
        req = Typhoeus::Request.new(uri, {
          method: :post,
          headers: {
            'Content-Type' => 'application/json',
            'User-Agent' => @user_agent,
            'Authorization' => ISUCARI_API_TOKEN
          },
          body: { reserve_id: rid }.to_json,
        })
        req.on_complete do |res|
          if res.code != 200
            raise Error, "status code #{res.code}; body #{res.body}"
          end
          results[rid] = JSON.parse(res.body)
        end
        hydra.queue(req)
      end
      hydra.run
      results
    end
  end
end
