class ESPN
  # API_KEY = "your key here"
  NOW_URL = "http://api.espn.com/v1/now?apikey=#{API_KEY}"

  def now(&callback)
    AFMotion::JSON.get(NOW_URL) do |result|
      callback.call result.object
    end
  end
end
