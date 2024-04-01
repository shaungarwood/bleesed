# frozen_string_literal: true

require "bleesed"
require "vcr"
require "cgi"
require "pry"

require "dotenv"

Dotenv.load('.env.test')

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.default_cassette_options = {record: :once}
  c.hook_into :faraday

  c.define_cassette_placeholder("<LOGIN_EMAIL>") { CGI.escape(ENV["EMAIL"]) }
  c.define_cassette_placeholder("<LOGIN_PASSWORD>") { ENV["PASSWORD"] }
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
