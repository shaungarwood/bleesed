RSpec.shared_context "client setup" do
  let(:client) do
    email = ENV["EMAIL"]
    password = ENV["PASSWORD"]
    temp_client = Bleesed::Client.new(email: email, password: password)
    VCR.use_cassette("login") { temp_client.login! }
    temp_client
  end
end
