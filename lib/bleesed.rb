# frozen_string_literal: true

require_relative "bleesed/version"

require "faraday"
require "faraday-cookie_jar"
require "nokogiri"
require "json"

URL = "https://app.blesseveryhome.com/"

module Bleesed
  class Client
    # GOABOUT: pass options hash to faraday
    def initialize(email = nil, password = nil, proxy = nil)
      @email = email
      @password = password
      @proxy = proxy
    end

    def connection
      @connection ||= Faraday.new(url: URL, proxy: @proxy) do |faraday|
        faraday.use :cookie_jar
        faraday.request :url_encoded
        faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end
    end

    def login
      response = connection.post("login/index.php",
        {email: @email, password: @password})
      puts response.body
    end
  end

  class Error < StandardError; end
end
