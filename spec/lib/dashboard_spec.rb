# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bleesed::Dashboard do
  include_context "client setup"

  describe "#switch_role" do
    it "returns the new role id" do
      VCR.use_cassette("switch_role") do
        client.login!

        other_role_id = client.other_roles.first[:role_id]

        expect(client.switch_role(other_role_id)).to eq(other_role_id)
        expect(client.role_id).to eq(other_role_id)
      end
    end

    context "with an invalid role id" do
      it "raises an error" do
        VCR.use_cassette("switch_role_invalid") do
          client.login!
          expect { client.switch_role("invalid") }.to raise_error(Bleesed::Error)
        end
      end
    end
  end

  describe "#get_global_stats" do
    it "returns the global stats" do
      VCR.use_cassette("global_stats") do
        response = client.get_global_stats

        expect(response).not_to be_empty
        expect(response.keys).to include(
          *%i[adopted discipled pray care share]
        )
        expect(response.values.sum).to be > 0
      end
    end
  end

  describe "#get_national_stats" do
    it "returns the national stats" do
      VCR.use_cassette("national_stats") do
        response = client.get_national_stats

        expect(response).not_to be_empty
        expect(response.keys).to include(
          *%i[adopted discipled pray care share]
        )
        expect(response.values.sum).to be > 0
      end
    end
  end

  describe "#get_state_stats" do
    it "returns the state stats" do
      VCR.use_cassette("state_stats") do
        response = client.get_state_stats("CO")

        expect(response).not_to be_empty
        expect(response.keys).to include(
          *%i[adopted discipled pray care share]
        )
        expect(response.values.sum).to be > 0
      end
    end
  end

  describe "#get_local_stats" do
    it "returns the local stats" do
      VCR.use_cassette("local_stats") do
        response = client.get_local_stats

        expect(response).not_to be_empty
        expect(response.keys).to include(
          *%i[adopted discipled pray care share]
        )
        expect(response.values.sum).to be > 0
      end
    end
  end

  describe "#get_lights_recruited" do
    it "returns the lights recreuited" do
      VCR.use_cassette("lights_recruited") do
        response = client.get_lights_recruited

        expect(response).to be_a(Integer)
      end
    end
  end
end
