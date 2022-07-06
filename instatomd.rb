# nethttp2.rb
require 'uri'
require 'net/http'

uri = URI('https://api.nasa.gov/planetary/apod')
params = { :api_key => 'your_api_key' }
uri.query = URI.encode_www_form(params)

res = Net::HTTP.get_response(uri)
puts res.body if res.is_a?(Net::HTTPSuccess)