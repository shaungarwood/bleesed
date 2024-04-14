# frozen_string_literal: true

module Bleesed
  module Neighbors
    def remove_household_name(item_id)
      post_form = edit_household(item_id)

      connection.port = 443
      response = connection.post("light/neighborhood/public.php?") do |req|
        req.params = {plID: item_id, pagetype: "light", pagerole: role_id}
        req.body = post_form
      end

      response.status == 302
    end

    def dashboard_neighbors
      response = request(path: "light/progress/", params: {pagerole: 439271, pagetype: "light"})
      parse_dashboard_neighbors(response)
    end

    def map_neighbors
      payload = map_neighbors_payload
      response = api_request(body: payload.to_json)
    end

    def map_neighbors_details(item_id)
      payload = map_neighbors_details_payload(item_id)
      api_request(body: payload.to_json)
    end

    def touch_house(item_id, verb: nil)
      status = case verb
      when 'pray'
        1
      when 'care'
        2
      when 'share'
        3
      when 'disciple'
        4
      else
        raise ArgumentError, "Invalid verb"
      end

      payload = touch_house_payload(item_id, status)
      api_request(body: payload.to_json)
    end

    private

    def parse_json(response)
      unless response.reason_phrase == "OK" || response.body.start_with?("{")
        raise UnknownAPIError, "Unknown API response"
      end

      payload = JSON.parse(response.body)
      if payload["s"] # status?
        return payload["p"] || "Success" # payload?
      end

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

    def touch_house_payload(item_id, status = 1)
      # status 1 == pray
      # status 2 == care
      # status 3 == share
      # status 4 == disciple
      {
        t: "stats_counterUpdate",
        p: {
          change: 1,
          prayerListItemId: item_id.to_i,
          status: status
        },
        r: {
          id: role_id,
          type: "light"
        }
      }

    end

    def map_neighbors_payload
      {
        t: "prayerList_neighborhoodListGetForMap",
        p: {},
        r: {
          id: role_id,
          type: "light"
        }
      }
    end

    def map_neighbors_details_payload(item_id)
      {
        t: "prayerListItem_neighborhoodListGetDetails",
        p: {prayerListItemId: item_id.to_i},
        r: {
          id: role_id,
          type: "light"
        }
      }
    end

    def edit_household(item_id)
      connection.port = 443
      response = connection.get("light/neighborhood/public.php?") do |req|
        req.params = {plID: item_id, pagetype: "light", pagerole: role_id}
      end

      parse_edit_household_form(response)
    end

    def parse_edit_household_form(response)
      doc = Nokogiri::HTML(response.body)
      form = doc.css("div.editHouseholdPopup.newPopupContainer.js-popupCloser form")
      post_form = form.css("input").each_with_object({}) do |input, hash|
        hash[input["name"]] = input["value"]
      end
      post_form.delete(nil)
      post_form
    end
  end

  class UnknownAPIError < StandardError; end
end
