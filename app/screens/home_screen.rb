class HomeScreen < PM::TableScreen
  title "Home"

  def table_data
    [{
      title: "",
      cells: Array(@headlines)
    }]
  end

  def on_load
    ESPN.new.now do |response|
      @headlines = response["feed"].map do |f|
        {
          title: f["headline"],
          action: :tap_headline,
          arguments: { links: f["links"] }
        }
      end
      update_table_data
    end
  end

  def tap_headline(args={})
    PM.logger.debug args[:links]
  end
end
