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

    def get_national_stats
      stats(level: 'n', id: 'US')
    end

    def get_state_stats(state_id)
      stats(level: 's', id: state_id)
    end

    def get_global_stats
      go_to_dashboard if @global_hash.nil?

      stats(level: 'g', id: @global_hash)
    end

    def get_local_stats
      go_to_dashboard if @local_hash.nil?

      stats(level: 'l', id: @local_hash)
    end

    def get_lights_recruited
      go_to_dashboard if @local_hash.nil?

      response = api_request(
        body: stats_payload(level: 'l', id: @global_hash, type: 'lightsRecruited').to_json
      )
      response[0][0]
    end

    private

    def stats(level: 'n', id: 'US')
      all_stats = {}
      %w[
        prayCareShare
        adoptedDiscipled
      ].each do |type|
        response = api_request(
          body: stats_payload(level:, id:, type:).to_json
        )
        all_stats.merge!(parse_stats(response:, type:))
      end
      all_stats
    end

    def stats_payload(level:, id:, type:)
      payload = { "t": type }

      key = 'id'
      key = 'hash' if level == 'l' || type == 'lightsRecruited'
      payload[key] = id

      payload['level'] = level unless type == 'lightsRecruited'

      {
        "p": payload,
        "r": {
          "id": role_id,
          "type": "light"
        },
        "t": "stats_globalDashboardStatUpdate"
      }
    end

    def parse_stats(response:, type:)
      case type
      when 'prayCareShare'
        {
          pray: response[0][0],
          care: response[1][0],
          share: response[2][0]
        }
      when 'adoptedDiscipled'
        {
          adopted: response[0][0],
          discipled: response[1][0]
        }
      end
    end

    def go_to_dashboard(role_id: @role_id)
      connection.port = 443
      response = connection.get("light/progress/?pagetype=light&pagerole=#{role_id}")
      if response.status == 200
        doc = Nokogiri::HTML(response.body)
        set_other_roles(doc)
        set_stats_hashes(doc)
        @role_id = role_id
      else
        false
      end
    end

    def set_stats_hashes(doc)
      elements = doc.css('[data-x]')
      hashes = elements.map do |element|
        begin
          JSON.parse(element['data-x'])
        rescue JSON::ParserError
          {}
        end
      end

      @local_hash = hashes.find do |hash|
        hash['level'] == 'l'
      end&.fetch('hash', nil)

      @global_hash = hashes.find do |hash|
        hash['level'] == 'g'
      end&.fetch('id', nil)
    end

    def parse_role_id(link)
      link.split("pagerole=").last&.to_i
    end

    def set_other_roles(doc)
      roles = doc.css("a.statusBarMyAcountsDropdown-row")
      roles = roles.map do |role|
        {name: role.text.strip, role_id: parse_role_id(role["href"])}
      end
      roles.delete_if { |role| role[:role_id] == "/person" }
      @other_roles = roles
    end
  end
end
