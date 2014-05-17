describe ESPN do
  
  before do
    @espn = ESPN.new
  end

  it "is a class" do
    @espn.should.be.kind_of(ESPN)
  end

  it "can get a response from ESPN now" do
    @espn.now do |response|
      response.should.be.kind_of(Hash)
      resume
    end
    wait {}
  end

  it "returns a list of well-formatted titles and links" do
    @espn.news do |articles|
      articles.should.be.kind_of?(Array)
      articles.length.should.be > 0
      articles.first.should.be.kind_of?(Hash)
      articles.first[:title].should.be.kind_of?(String)
      articles.first[:title].length.should.be > 0
      articles.first[:link].should.be.kind_of?(NSURL)
      resume
    end
    wait {}
  end

end
