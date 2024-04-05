# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bleesed::Client do
  subject(:client) do
    described_class.new(email: ENV["EMAIL"], password: ENV["PASSWORD"])
  end

  describe "#login!" do
    it "returns and saves the role id" do
      role_id_regex = /^\d{6,}$/

      VCR.use_cassette("login") do
        expect(client.login!).to match(role_id_regex)
        expect(client.role_id).to match(role_id_regex)
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
end
