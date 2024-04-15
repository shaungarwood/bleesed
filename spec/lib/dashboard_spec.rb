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
end
