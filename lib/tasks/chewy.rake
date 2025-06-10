namespace :chewy do
  desc "Reset and reindex all indices"
  task reset_all: :environment do
    Chewy::Index.descendants.each do |index|
      puts "Resetting #{index}..."
      index.reset!
    end
  end

  desc "Reset and reindex user index"
  task reset_users: :environment do
    puts "Resetting UserIndex..."
    UserIndex.reset!
  end

  desc "Reset and reindex tweet index"
  task reset_tweets: :environment do
    puts "Resetting TweetIndex..."
    TweetIndex.reset!
  end
end
