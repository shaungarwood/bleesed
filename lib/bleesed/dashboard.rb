# frozen_string_literal: true

module Bleesed
  module Dashboard
    def switch_role(role_id)
      if go_to_dashboard(role_id: role_id)
        role_id
      else
        raise Error, "Switch role failed"
      end
    end

    private

    def go_to_dashboard(role_id: @role_id)
      connection.port = 443
      response = connection.get("light/progress/?pagetype=light&pagerole=#{role_id}")
      if response.status == 200
        @other_roles = parse_other_roles(response.body)
        @role_id = role_id
      else
        false
      end
    end

    def parse_role_id(link)
      link.split("pagerole=").last&.to_i
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
end
