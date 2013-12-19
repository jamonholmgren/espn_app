describe ESPN do
  
  before do
    @espn = ESPN.new
  end

  it "is a class" do
    @espn.should.be.kind_of(ESPN)
  end

  it "can get a response from ESPN now" do
    @request = @espn.now do |response|
      response.should.be.kind_of(Hash)
      resume
    end
    wait {}
  end
end
