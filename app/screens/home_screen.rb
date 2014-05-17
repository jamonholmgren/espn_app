class HomeScreen < PM::TableScreen
  refreshable
  title "Home"

  def on_load
    @layout = HomeLayout.new
    self.tableView = @layout.view
    
    on_refresh
  end

  def table_data
    [{
      title: "",
      cells: Array(@headlines)
    }]
  end

  def on_refresh
    ESPN.new.news do |articles|
      @headlines = articles.map do |article|
        {
          title: article[:title],
          action: :tap_headline,
          arguments: article
        }
      end
      update_table_data
      stop_refreshing
    end
  end

  def tap_headline(args)
    open NewsScreen.new(news: args)
  end
end
