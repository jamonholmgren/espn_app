class HomeScreen < PM::TableScreen
  refreshable
  title "Home"

  def table_data
    [{
      title: "",
      cells: Array(@headlines)
    }]
  end

  def on_load
    on_refresh
  end

  def on_refresh
    ESPN.new.now do |response|
      @headlines = response["feed"].map do |f|
        {
          title: f["headline"],
          action: :tap_headline,
          arguments: { links: f["links"] }
        }
      end
      update_table_data
      stop_refreshing
    end
  end

  def extract_href(links)
    while links.is_a?(Hash)
      if links["href"]
        links = links["href"]
      else
        links = links.values.first # Extract value
      end
    end
    links
  end

  def tap_headline(args={})
    link = extract_href(args[:links])

    if link.is_a?(String)
      UIApplication.sharedApplication.openURL(NSURL.URLWithString(link))
    end
  end
end
