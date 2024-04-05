# frozen_string_literal: true

URL = "https://app.blesseveryhome.com/"

module Bleesed
  class Client
    attr_reader :email, :proxy, :token, :role_id, :other_roles
    # GOABOUT: pass options hash to faraday
    def initialize(email: nil, password: nil, proxy: nil)
      @email = email
      @password = password
      @proxy = proxy
      @token = nil
      @role_id = nil
    end

    def login!
      get_token

      response = connection.post("login/index.php",
        {
          forgodseternalpurpose: token,
          returnURL: "",
          forcedEmail: "",
          email: @email,
          password: @password
        })

      redirect = response.headers["location"]

      if redirect&.include?("/light/progress/?pagetype=light&pagerole=")
        @role_id = parse_role_id(redirect)
        get_other_roles(redirect)

        @role_id
      elsif response.body.include?("Incorrect credentials given!")
        raise UnauthorizedError, "Login failed"
      else
        raise Error, "Login failed"
      end
    end

    def logout!
      response = connection.get("login/logout.php")
      response.status == 302 &&
        response.headers["location"] == URL + "login/index.php"
    end

    private

    def parse_role_id(link)
      link.split("pagerole=").last
    end

    def connection
      @connection ||= Faraday.new(url: URL, proxy: @proxy) do |faraday|
        faraday.use :cookie_jar
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
      end
    end

    def get_token
      res = connection.get("login/index.php")
      doc = Nokogiri::HTML(res.body)
      @token = doc.css('input[name="forgodseternalpurpose"]').first["value"]
    end

    def get_other_roles(link)
      response = connection.get(link)
      doc = Nokogiri::HTML(response.body)
      roles = doc.css("a.statusBarMyAcountsDropdown-row")
      @other_roles = roles.map do |role|
        {name: role.text.strip, role_id: parse_role_id(role["href"])}
      end
      @other_roles.delete_if { |role| role[:role_id] == "/person" }
      @other_roles
    end
  end

  class Error < StandardError; end

  class UnauthorizedError < Error; end
end
