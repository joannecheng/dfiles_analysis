require 'faraday'
require_relative 'db_setup'

# questions:
# what's the language breakdown of all of github users's dotfile?
# how many emacs users are there? vim users? other editor configurations?
# what are language choices of emacs users? vim users?

db = DatabaseSetup.new
db.setup

token = ENV['GITHUB_ACCESS_TOKEN']

rows = db.repos_to_collect

rows.each do |row|
  url = row[2] + "?access_token=#{token}"
  response = Faraday.get(url).body

  db.insert_languages(response, row[0])
end
