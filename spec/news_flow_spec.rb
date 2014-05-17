describe "Selecting a news article, reading it, going back" do
  tests HomeScreen

  def controller
    @controller ||= HomeScreen.new(nav_bar: true)
  end
  alias :screen :controller

  it "shows a list of articles, allows opening one" do
    screen.on_load
    wait 1 do
      screen.rmq(UITableViewCell).length.should.be >= 8
      tap screen.rmq(UITableViewCell).last.get
      wait 0.6 do
        # At the ESPN website
        visible = screen.navigationController.visibleViewController
        visible.should.be.kind_of?(NewsScreen)
        visible.rmq(UIWebView).length.should == 1
        visible.content.should == screen.table_data.first[:cells].first[:arguments][:link]
      end
    end
  end

end
