require 'faraday'
require_relative 'db_setup'

# questions:
# what's the language breakdown of all of github users's dotfile?
# how many emacs users are there? vim users? other editor configurations?
# what are language choices of emacs users? vim users?

db = DatabaseSetup.new
db.setup

token = ENV['GITHUB_ACCESS_TOKEN']

ids = db.repo_ids_to_collect

ids.each do |id|
  row = db.find_repo(id)

  url = row[2] + "?access_token=#{token}"
  response = Faraday.get(url).body
  if response =~ /rate limit exceeded/
    puts "rate limit exceeded"
    next
  end
  db.insert_languages(response, id)
end
