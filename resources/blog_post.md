*Note: this is a sequel to this post: [http://jamonholmgren.com/building-an-espn-app-using-rubymotion-promotion-and-tdd](http://jamonholmgren.com/building-an-espn-app-using-rubymotion-promotion-and-tdd)*

In the original article, I showed you how to get started with TDD. In this second installment I'm going to flesh out the UI on our app and fix a few things.

If you've followed along so far, just pick up where you left off. Otherwise, clone [the source](https://github.com/jamonholmgren/espn_app) and check out `article-1`. You'll need to provide your own [ESPN Now API token](http://developer.espn.com/) in `app/api/espn.rb`:

```ruby
class ESPN
  API_KEY = "your key here"
  NOW_URL = "http://api.espn.com/v1/now?apikey=#{API_KEY}"
  # ...
```

### Update gems

It's been a few months since part 1 of this series and some gems have been updated. So let's change our Gemfile:

```ruby
source "https://rubygems.org"

gem "rake"
gem "ProMotion", github: "clearsightstudio/ProMotion", branch: "pm2"
gem "afmotion", "~> 2.1.4"
gem "motion-stump", "~> 0.3.2"
```

Run `bundle update` to get the latest. You'll notice I'm pulling ProMotion 2.0 from the bleeding edge branch. This is a horrible idea, because I'm breaking ProMotion 2.0 all the time. But this is my blog and I can break things if I want to. ;-)

You will also need to run `rake pod:install` to get the latest CocoaPods. And run `rake clean` to ensure everything updates properly.

Run your trusty spec watcher, `when-files-change -- "clear && bundle exec rake spec"`, and your tests should still pass. Unless I broke ProMotion 2.0 again.

```ruby
ESPN
  - is a class
  - can get a response from ESPN now

HomeScreen
  - is a TableScreen
  - loads headlines
  - opens the link URL when you tap a cell

5 specifications (6 requirements), 0 failures, 0 errors
```

### Load up the app

Load up the app into the simulator with `rake`. You will see something like this:

![Screen Shot 2014-01-26 at 9,49,28 PM](https://roon-media.s3.amazonaws.com/blogs/16412/0t3c15433i05143e3f3b1K2D3R2Z0n1R/giant.png)

Kinda ugly, if you ask me (and you did, you did).

Kill the app with `exit` and pull up your editor. Make sure your spec watcher is running.

### MotionKit

Now, the exciting part. Over the last couple months, Colin T. A. Gray and I have been working on a new styling system called [MotionKit](https://github.com/rubymotion/motion-kit). This awesome library makes layout and styling much, much easier and more intuitive than ever before.

Let's see it in action!

In your Gemfile:

```ruby
gem "motion-kit", "~> 0.9"
gem "sweet-kit", "~> 0.2" # Sugarcube + more for MotionKit
```

Bundle up, then follow me into the spec folder, back into our `home_spec.rb` file. Near the end, add another spec:

```ruby
  # ...

  it "has a background color of :whitesmoke" do
    screen.tableView.backgroundColor.should == :whitesmoke.uicolor
  end

end
```

This should fail, since the background color is currently white, not white smoke.

```bash
HomeScreen
  - is a TableScreen
  - loads headlines
  - opens the link URL when you tap a cell
  - has a background color of #F5F5F5 [FAILED - :white.uicolor.==(:whitesmoke.uicolor) failed]

Bacon::Error: :white.uicolor.==(:whitesmoke.uicolor) failed
  spec.rb:700:in `satisfy:': HomeScreen - has a background color of :whitesmoke

6 specifications (7 requirements), 1 failures, 0 errors
```

Let's make it pass! Make a folder in `/app` called `layouts` and create a new file in there called `home_layout.rb`. 

```ruby
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
```

Then, go into your `home_screen.rb` folder and add MotionKit to the `on_load` method:

```ruby
  def on_load
    @layout = HomeLayout.new
    self.tableView = @layout.view
    
    on_refresh
  end
```

Running your specs should get you something like this:

```
ESPN
  - is a class
  - can get a response from ESPN now

HomeScreen
  - is a TableScreen
  - loads headlines
  - opens the link URL when you tap a cell
  - has a background color of :whitesmoke

6 specifications (7 requirements), 0 failures, 0 errors
```

Man can't live by tests alone...we need to see this! Spin up the app with `rake` and take a look.

![7js0az8kl0](https://roon-media.s3.amazonaws.com/blogs/16412/0k0i1f1Y3b0F220w3S1C1h3p3a3K2e36/giant.png)

The white cells nearly obscure the background, but it's there. We have a lot of work to do, it seems. But everything is working!

### Cleaning up the data

The data we're getting from the ESPN Now API is a bit messy, so it's time that we turn that into something simpler and more consistent.

Open `spec/espn_spec.rb` and add the following new specification:

```ruby
  it "returns a list of well-formatted titles and links" do
    @request = @espn.news do |articles|
      articles.should.be.kind_of?(Array)
      articles.length.should.be > 0
      articles.first.should.be.kind_of?(Hash)
      articles.first[:title].should.be.kind_of?(String)
      articles.first[:title].length.should.be > 0
      articles.first[:link].should.be.kind_of?(NSURL)
    end
    wait {}
  end
```

You'll get:

```
NoMethodError: undefined method `news' for #<ESPN:0x9b82db0>
```

Let's add that method now, plus some helpers. Open up `app/api/espn.rb`.

```ruby
  # ...

  def news(&callback)
    return @news_data if @news_data
    now do |response|
      @news_data = response["feed"].map do |article|
        format_article article
      end
      callback.call @news_data
    end
  end

  private

  def format_article(article)
    {
      title: article["headline"],
      link:  NSURL.URLWithString(extract_href(article["links"]))
    }
  end

  def extract_href(links)
    try_hash(links, "mobile", "href") ||
    try_hash(links, "web", "href") ||
    "http://espn.com"
  end

  # Reaches deep into a hash of hashes, returning nil if any
  # of the keys doesn't exist
  def try_hash(h, *keys)
    keys.each { |k| h = h[k] if h.is_a?(Hash) }
    h
  end

end
```

I won't bother going line-by-line on those methods. The private ones are a bit obscure, but you can puzzle it out if you like Ruby code. In the example repo, I've put an example API response in `resources/example_response.rb`, so you can see how I'm extracting that information from the response.

Let's also add a little memoization to reduce the number of hits on the API feed. In the `now` method, add a few things:

```ruby
  def now(&callback)
    return callback.call @now_data if @now_data
    AFMotion::JSON.get(NOW_URL) do |result|
      @now_data = result.object
      callback.call @now_data
    end
  end
```

The `@now_data` will short-circuit (sometimes called an "early out") when the data has already been fetched, and the callback will be called instantaneously.

Running the tests, I get a nice passing score:

```
7 specifications (13 requirements), 0 failures, 0 errors
```

Now that we have a nicer data set, let's go back to our `home_screen.rb` and clean it up a bit.

```ruby
  # ...

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

  def tap_headline(news)
    open NewsScreen.new(news: args)
  end

end
```

We converted the `ESPN.new.now` to our new `ESPN.new.news` and simplified the code, removing our old `extract_hrefs` method in the process.

Running the app, not much has changed. If you tap a cell the app will crash because we haven't implemented the `NewsScreen` yet.

We also need to change a test. In `home_screen_spec.rb`, change the `it "opens the link URL when you tap a cell"` to this one:

```ruby
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
```

Here we are simplifying the data to look like the real data and then setting a mock expectation on the `open` method of the screen. It won't pass, as we don't have the NewsScreen yet.

### Integration test

Essentially, we want the app to open a new screen with a webview showing the article. To do this, an integration test will come in handy.

Make a new file at `spec/news_flow_spec.rb`. We'll test the "flow" of reading a news article here.

My good friend Todd Werth over at InfiniteRed has a gem called [RMQ](https://github.com/infinitered/rmq). RMQ is essentially a front end engineer's toolkit to build, style, and manipulate the UI elements of your screens. RMQ works wonderfully with ProMotion and I'll be showcasing it in future blog posts.

But for now, we're going to use it a little like jQuery: as a way to select our view elements easily for testing.

In our Gemfile:

```ruby
gem "ruby_motion_query", "~> 0.5.7"
```

While we're in there, let's also add a couple other gems that I like to have in every project.

```ruby
gem "motion-redgreen", "~> 0.1" # Nicer test output
gem "awesome_print_motion", "~> 0.1" # Use `ap` instead of `puts`
```

Bundle, then go back into the `spec/news_flow_spec.rb` file.

```ruby
describe "Selecting a news article, reading it, going back" do
  tests HomeScreen

  def controller
    @controller ||= HomeScreen.new(nav_bar: true)
  end
  alias :screen :controller

  it "shows a list of articles" do
    screen.on_load
    wait 1 do
      screen.rmq(UITableViewCell).length.should.be >= 8
    end
  end

end
```

The tests will have a couple failures; we need that NewsScreen now. So let's make it.

In `app/screens/news_screen.rb`, drop in this code:

```ruby
class NewsScreen < PM::WebScreen
  attr_accessor :news

  def will_appear
    self.title = self.news[:title] || "ESPN.com"
  end

  def content
    self.news[:link] || NSURL.URLWithString("http://espn.go.com/")
  end

end
```

This is a ProMotion WebScreen, which is an easy way to show a website or local HTML in your app.

I won't write a test for this WebScreen. I think you should try one or two yourself to see how it goes (yes, I'm assigning you homework). *Hint: try instantiating one like I've done with my unit tests and then make sure it returns the right URL from `content`.*

Your tests should be golden now!

```
8 specifications (14 requirements), 0 failures, 0 errors
```

Let's complete the `news_flow_spec.rb` tests.

```ruby
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
```

Run them and it should pass. Go ahead and test it yourself too by running `rake`.

![Screen Shot 2014-05-17 at 4,07,23 PM](https://roon-media.s3.amazonaws.com/blogs/16412/0Y1p1f1N3F3v241H0D2T2h3Z0R3x0G2y/giant.png)
![Screen Shot 2014-05-17 at 4,06,07 PM](https://roon-media.s3.amazonaws.com/blogs/16412/3G0A2X200k3F2p003i1Q0Z161y312C0D/giant.png)

...to be continued...


