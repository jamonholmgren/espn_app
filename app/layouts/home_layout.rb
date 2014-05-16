class HomeLayout < MK::Layout

  def layout
    root UITableView, :news_ticker do
    end
  end

  protected

  def news_ticker_style
    background_color :whitesmoke.uicolor
  end

end
