class ESPN
  # API_KEY = "your key here"
  NOW_URL = "http://api.espn.com/v1/now?apikey=#{API_KEY}"

  def now(&callback)
    return callback.call @now_data if @now_data
    AFMotion::JSON.get(NOW_URL) do |result|
      @now_data = result.object
      callback.call @now_data
    end
  end

  def news(&callback)
    return @news_data if @news_data
    now do |response|
      @news_data = response["feed"].map do |article|
        format_article article
      end
      callback.call @news_data
    end
  end

  private

  def format_article(article)
    {
      title: article["headline"],
      link:  NSURL.URLWithString(extract_href(article["links"]))
    }
  end

  def extract_href(links)
    try_hash(links, "mobile", "href") ||
    try_hash(links, "web", "href") ||
    "http://espn.com"
  end

  # Reaches deep into a hash of hashes, returning nil if any
  # of the keys doesn't exist
  def try_hash(h, *keys)
    keys.each { |k| h = h[k] if h.is_a?(Hash) }
    h
  end

end
