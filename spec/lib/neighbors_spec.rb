# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bleesed::Client do
  subject(:client) do
    temp_client = described_class.new(email: ENV["EMAIL"], password: ENV["PASSWORD"])
    VCR.use_cassette("login") { temp_client.login! }
    temp_client
  end

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
end
