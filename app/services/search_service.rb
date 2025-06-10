class SearchService
  def self.search_users(query, page: 1, per_page: 20)
    Rails.logger.debug "Searching for users with query: #{query}"
    results = UserIndex
      .query(bool: {
        should: [
          {
            multi_match: {
              query: query,
              fields: ["username^3", "email"],
              fuzziness: "AUTO"
            }
          },
          {
            prefix: {
              username: query.downcase
            }
          }
        ]
      })
      .limit(per_page)
      .objects
    Rails.logger.debug "Found #{results.count} users"
    Rails.logger.debug "Users found: #{results.map(&:username).join(', ')}"
    results
  end

  def self.search_tweets(query, page: 1, per_page: 20)
    TweetIndex
      .query(multi_match: {
        query: query,
        fields: [ "body^3", "user_name^2", "user_email" ],
        fuzziness: "AUTO"
      })
      .limit(per_page)
      .objects
  end

  def self.search_all(query, page: 1, per_page: 20)
    {
      users: search_users(query, page: page, per_page: per_page),
      tweets: search_tweets(query, page: page, per_page: per_page)
    }
  end
end
