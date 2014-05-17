class NewsScreen < PM::WebScreen
  attr_accessor :news

  def will_appear
    self.title = self.news[:title] || "ESPN.com"
  end

  def content
    self.news[:link] || NSURL.URLWithString("http://espn.go.com/")
  end

end
