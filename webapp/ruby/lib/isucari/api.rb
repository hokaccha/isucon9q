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

    def make_request(uri, method, body)
      req = Typhoeus::Request.new(uri, {
        method: method,
        headers: {
          'Content-Type' => 'application/json',
          'User-Agent' => @user_agent,
          'Authorization' => ISUCARI_API_TOKEN
        },
        body: body.to_json,
      })
    end

    def shipment_status_parallel(shipment_url, reserve_ids)
      return {} if reserve_ids.empty?
      uri = URI.parse("#{shipment_url}/status")
      hydra = Typhoeus::Hydra.hydra
      results = {}
      reserve_ids.each do |rid|
        req = make_request(uri, :post, { reserve_id: rid })
        req.on_complete do |res|
          if res.code != 200
            raise Error, "status code #{res.code}; body #{res.body}"
          end
          results[rid] = JSON.parse(res.body)['status']
        end
        hydra.queue(req)
      end
      hydra.run
      results
    end

    def buy(shipment_url:, shipment_body:, payment_url:, payment_body:)
      scr = nil
      pstr = nil

      hydra = Typhoeus::Hydra.hydra

      req1 = make_request("#{shipment_url}/create", :post, shipment_body)
      req1.on_complete do |res|
        if res.code != 200
          raise Error, "status code #{res.code}; body #{res.body}"
        end
        scr = JSON.parse(res.body)
      end
      hydra.queue(req1)

      req2 = make_request("#{payment_url}/token", :post, payment_body)
      req2.on_complete do |res|
        if res.code != 200
          raise Error, "status code #{res.code}; body #{res.body}"
        end
        pstr = JSON.parse(res.body)
      end
      hydra.queue(req2)

      hydra.run

      [scr, pstr]
    end
  end
end
