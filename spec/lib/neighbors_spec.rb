# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bleesed::Neighbors do
  include_context "client setup"

  describe "#dashboard_neighbors" do
    it "returns the dashboard neighbors" do
      VCR.use_cassette("dashboard_neighbors") do
        expect(client.dashboard_neighbors).not_to be_empty
        expect(client.dashboard_neighbors.first.keys).to match_array(%i[name address])
      end
    end
  end

  describe "#map_neighbors" do
    it "returns the map neighbors" do
      VCR.use_cassette("map_neighbors") do
        map_neighbors = client.map_neighbors

        expect(map_neighbors).not_to be_empty
        expect(map_neighbors.keys).to match_array(%w[member prayers])
        expect(map_neighbors["prayers"].first.keys).to include(*%w[state lat lng])
      end
    end
  end

  describe "#map_neighbors_details" do
    it "returns the map neighbors details" do
      VCR.use_cassette("map_neighbors_details") do
        details = client.map_neighbors_details(10978278)

        expect(details).not_to be_empty
        expect(details.keys).to include(*%w[email phone label zip])
      end
    end

    it "raises an error with an invalid item id" do
      VCR.use_cassette("map_neighbors_details_invalid") do
        expect { client.map_neighbors_details(0) }.to raise_error(Bleesed::UnknownAPIError)
      end
    end
  end

  describe "#remove_household_name" do
    it "returns true" do
      VCR.use_cassette("remove_household_name") do
        expect(client.remove_household_name(10978278)).to eq(true)
      end
    end
  end

  describe "#touch_house" do
    it "returns status" do
      VCR.use_cassette("touch_house") do
        house_id = 10978278
        expect(client.touch_house(house_id, verb: "pray")).to eq("Success")
      end
    end

    it "raises an error when the house id is invalid" do
      VCR.use_cassette("touch_house_invalid_house") do
        house_id = 0
        expect { client.touch_house(house_id, verb: "pray") }.to raise_error(Bleesed::UnknownAPIError)
      end
    end

    it "raises an error with an invalid verb" do
      VCR.use_cassette("touch_house_invalid") do
        house_id = 10978278
        expect { client.touch_house(house_id, verb: "invalid") }.to raise_error(ArgumentError)
      end
    end
  end
end
