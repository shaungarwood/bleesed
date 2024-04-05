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
      response = connection.post("login/index.php", login_hash)

      redirect = response.headers["location"]

      if redirect&.include?("/light/progress/?pagetype=light&pagerole=")
        @role_id = parse_role_id(redirect)
        go_to_dashboard
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

    def switch_role(role_id)
      if go_to_dashboard(role_id: role_id)
        return role_id
      else
        raise Error, "Switch role failed"
      end
    end

    private

    def login_hash
      get_token if @token.nil?

      {
        forgodseternalpurpose: token,
        returnURL: "",
        forcedEmail: "",
        email: @email,
        password: @password
      }
    end

    def go_to_dashboard(role_id: @role_id)
      response = connection.get("light/progress/?pagetype=light&pagerole=#{role_id}")
      if response.status == 200
        @other_roles = parse_other_roles(response.body)
        @role_id = role_id
      else
        return false
      end
    end

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

    def parse_other_roles(page)
      doc = Nokogiri::HTML(page)
      roles = doc.css("a.statusBarMyAcountsDropdown-row")
      roles = roles.map do |role|
        {name: role.text.strip, role_id: parse_role_id(role["href"])}
      end
      roles.delete_if { |role| role[:role_id] == "/person" }
      roles
    end
  end

  class Error < StandardError; end

  class UnauthorizedError < Error; end
end
