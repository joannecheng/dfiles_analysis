require 'sqlite3'

class DatabaseSetup
  attr_reader :db

  def initialize
    @db = SQLite3::Database.new 'dotfile_search_results.db'
  end

  def setup
    db.execute <<-SQL
      create table if not exists search_results(
      repo_id int,
      full_name varchar(30),
      language_url varchar(30) unique
    );
    SQL

    db.execute <<-SQL
      create table if not exists language_results(
      repo_id int unique,
      language_breakdown text
      );
    SQL
  end

  def repos_to_collect
    db.execute('select * from search_results')
  end

  def insert_repos(dotfiles_repos)
    dotfiles_repos.each do |repo|
      puts "inserting #{repo['full_name']} into db"
      db.execute("INSERT INTO search_results (repo_id, full_name, language_url)
             VALUES (?, ?, ?)", [repo['id'], repo['full_name'], repo['languages_url']])
    end
  end

  def insert_languages(languages, id)
    puts "inserting #{languages} for repo #{id}"

    begin
      db.execute("INSERT INTO language_results (repo_id, language_breakdown)
             VALUES (?, ?)", [id, languages])
    rescue SQLite3::ConstraintException
      puts "already exists"
    end
  end

  def last_collected_repo_id
    rows = db.execute('select * from search_results')
    if rows.empty?
      0
    else
      rows.map { |r| r[0] }.last
    end
  end
end
