module ApplicationHelper
  def time_ago_in_words_localized(time)
    time_ago = time_ago_in_words(time)
    t("tweets.time_ago", time: time_ago)
  end
end
