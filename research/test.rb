#!/usr/bin/env ruby

require "faraday"
require "faraday-cookie_jar"
require "nokogiri"
require "json"
require "pry"

# url = 'https://app.blesseveryhome.com:1978/api/v1/neighborhoods'
url = "https://app.blesseveryhome.com/"

email = "censorshipwreck@gmail.com"
# proxy = 'http://localhost:8080'
proxy = nil

@connection = Faraday.new(url: url, proxy: proxy) do |conn|
  conn.use :cookie_jar
  conn.adapter Faraday.default_adapter # make requests with Net::HTTP
  conn.headers { "Content-Type" => "application/x-www-form-urlencoded" }
  conn.request :url_encoded
  # conn.request(:authorization, :basic, username, password)
end

res = @connection.get("login/index.php")
doc = Nokogiri::HTML(res.body)
token = doc.css('input[name="forgodseternalpurpose"]').first["value"]

@connection.post("login/index.php",
  {
    forgodseternalpurpose: token,
    returnURL: "",
    forcedEmail: "",
    email: email,
    password: password
  })

# must leave trailing slash ON url
res = @connection.get("light/progress/") do |req|
  req.params = {pagerole: 439271, pagetype: "light"}
end
doc = Nokogiri::HTML(res.body)
main_neighbors = doc.css("div.neighborhoodListMainPart").map do |neighbhor|
  {
    name: neighbhor.css("div.neighborhoodListName").text.strip,
    address: neighbhor.css("div.neighborhoodListAddress").text.strip
  }
end

def neighborhood(item_id = nil)
  payload = {
    t: "prayerList_neighborhoodListGetForMap",
    p: {},
    r: {
      id: 439329,
      type: "light"
    }
  }
  if item_id
    payload["t"] = "prayerListItem_neighborhoodListGetDetails"
    payload["p"] = {"prayerListItemId" => item_id.to_i}
  end

  @connection.port = 1978
  res = @connection.post do |req|
    req.body = payload.to_json
    req.headers[:content_type] = "application/json"
  end

  return res.reason_phrase unless res.reason_phrase == "OK"

  JSON.parse(res.body)
end

# neighborhood
# neighborhood(10946881)

binding.pry

puts "le fin"
