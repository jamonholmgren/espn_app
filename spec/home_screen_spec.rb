describe HomeScreen do
  tests HomeScreen

  def screen
    @controller
  end

  it "is a TableScreen" do
    screen.should.be.kind_of(PM::TableScreen)
  end

  it "loads headlines" do
    screen.on_load
    wait 2 do
      screen.table_data.first[:cells].length.should.be > 0
    end
  end
end
