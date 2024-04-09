# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bleesed::Client do
  let(:role_id_regex) { /^\d{6,}$/ }

  subject(:client) do
    described_class.new(email: ENV["EMAIL"], password: ENV["PASSWORD"])
  end

  describe "#login!" do
    it "returns and saves the role id" do
      VCR.use_cassette("login") do
        client.login!
        expect(client.role_id.to_s).to match(role_id_regex)
      end
    end

    it "saves the token" do
      VCR.use_cassette("login") do
        client.login!
        expect(client.token).not_to be_empty
        expect(client.token.size).to eq(32)
      end
    end

    it "saves the other roles" do
      VCR.use_cassette("login") do
        client.login!
        expect(client.other_roles).not_to be_empty
        expect(client.other_roles.first.keys).to match_array(%i[name role_id])
      end
    end

    context "with an invalid login" do
      it "raises an error" do
        VCR.use_cassette("login_invalid") do
          expect { client.login! }.to raise_error(Bleesed::UnauthorizedError)
        end
      end
    end
  end

  describe "#logout!" do
    it "returns something" do
      VCR.use_cassette("logout") do
        expect(client.logout!).to eq(true)
      end
    end
  end

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

  context "when passing a proxy" do
    it "uses the proxy" do
      proxy = "http://localhost:8080"

      VCR.use_cassette("login_proxy") do
        client = described_class.new(
          email: ENV["EMAIL"],
          password: ENV["PASSWORD"],
          proxy: proxy
        )

        expect(Faraday).to receive(:new).with(url: described_class::URL, proxy: proxy).and_call_original

        expect(client.login!.to_s).to match(role_id_regex)
      end
    end
  end
end
