# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bleesed::Client do
  subject(:client) do
    described_class.new(email: ENV['EMAIL'], password: ENV['PASSWORD'])
  end

  describe "#login!" do
    it "returns a redirect" do
      VCR.use_cassette("login") do
        expect(client.login!).to eq(302)
      end
    end
  end
end
