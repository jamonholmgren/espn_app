describe HomeScreen do
  tests HomeScreen

  def controller
    @controller ||= HomeScreen.new
  end
  alias :screen :controller

  it "is a TableScreen" do
    screen.should.be.kind_of(PM::TableScreen)
  end

  it "loads headlines" do
    screen.on_load
    wait 1 do
      screen.table_data.first[:cells].length.should.be > 0
    end
  end

  it "opens the link URL when you tap a cell" do
    stub_table_data = [{
      cells: [{ 
        title: "Test Title", 
        action: :tap_headline, 
        arguments: { title: "Test Title", link: "http://www.google.com" }
      }]
    }]

    screen.mock!(:open) do |*screens|
      screens.first.should.be.instance_of?(NewsScreen)
    end
    screen.stub!(:table_data, { return: stub_table_data })
    screen.update_table_data

    tap view("Test Title")
  end

  it "has a background color of :whitesmoke" do
    screen.tableView.backgroundColor.should == :whitesmoke.uicolor
  end

end
