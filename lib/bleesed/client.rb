# frozen_string_literal: true

URL = "https://app.blesseveryhome.com/"

module Bleesed
  class Client
    # GOABOUT: pass options hash to faraday
    def initialize(email: nil, password: nil, proxy: nil)
      @email = email
      @password = password
      @proxy = proxy
      @token = nil
    end

    def login!
      response = connection.post("login/index.php",
        {
          forgodseternalpurpose: token,
          returnURL: "",
          forcedEmail: "",
          email: @email,
          password: @password
        }
      )
      response.status
    end

    private

    def connection
      @connection ||= Faraday.new(url: URL, proxy: @proxy) do |faraday|
        faraday.use :cookie_jar
        faraday.request :url_encoded
        faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end
    end

    def token
      res = connection.get("login/index.php")
      doc = Nokogiri::HTML(res.body)
      doc.css('input[name="forgodseternalpurpose"]').first["value"]
    end
  end

  class Error < StandardError; end
end
