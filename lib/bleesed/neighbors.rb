# frozen_string_literal: true

module Bleesed
  class Client
    def dashboard_neighbors
      connection.port = 443
      response = connection.get("light/progress/") do |req|
        req.params = {pagerole: 439271, pagetype: "light"}
      end
      parse_dashboard_neighbors(response)
    end

    def map_neighbors
      payload = map_neighbors_payload

      connection.port = 1978
      response = connection.post do |req|
        req.body = payload.to_json
        req.headers[:content_type] = "application/json"
      end

      parse_json(response)
    end

    def map_neighbors_details(item_id)
      payload = map_neighbors_details_payload(item_id)

      connection.port = 1978
      response = connection.post do |req|
        req.body = payload.to_json
        req.headers[:content_type] = "application/json"
      end

      parse_json(response)
    end

    private

    def parse_json(response)
      unless response.reason_phrase == "OK" || response.body.start_with?("{")
        raise UnknownAPIError, "Unknown API response"
      end

      payload = JSON.parse(response.body)
      return payload["p"] if payload["s"] # payload/status?

      raise UnknownAPIError, "Unknown API error"
    end

    def parse_dashboard_neighbors(response)
      doc = Nokogiri::HTML(response.body)
      doc.css("div.neighborhoodListMainPart").map do |neighbhor|
        {
          name: neighbhor.css("div.neighborhoodListName").text.strip,
          address: neighbhor.css("div.neighborhoodListAddress").text.strip
        }
      end
    end

    def map_neighbors_payload
      {
        t: "prayerList_neighborhoodListGetForMap",
        p: {},
        r: {
          id: role_id.to_i,
          type: "light"
        }
      }
    end

    def map_neighbors_details_payload(item_id)
      {
        t: "prayerListItem_neighborhoodListGetDetails",
        p: {prayerListItemId: item_id.to_i},
        r: {
          id: role_id.to_i,
          type: "light"
        }
      }
    end
  end

  class UnknownAPIError < StandardError; end
end
