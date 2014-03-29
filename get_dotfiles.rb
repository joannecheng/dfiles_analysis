require 'faraday'
require 'json'
require_relative 'db_setup'

db = DatabaseSetup.new

token = ENV['GITHUB_ACCESS_TOKEN']

repo_id = db.last_collected_repo_id
puts repo_id

5000.times do |i|
  search_url = "https://api.github.com/repositories?since=#{repo_id}&per_page=100" +
    "&access_token=#{token}"
  response = JSON.parse Faraday.get(search_url).body

  ids = response.map { |r| r["id"] }

  db.insert_repos(response.select {|r| r['name'] =~ /dot?.file/ })

  repo_id = ids.last
  puts "procesing page #{i}"
end

