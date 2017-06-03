# Browser class to handle the browser initialize/destroy workflow
module Browser
  def self.setup_browser
    ENV['BROWSER'] = 'headless' unless ENV['BROWSER']
    browser_name = ENV['BROWSER'].downcase.to_sym

    if ENV['SELENIUM_SERVER']
      setup_remote_driver browser_name
    elsif browser_name == :headless
      setup_headless_mode
    else
      @browser = Selenium::WebDriver.for browser_name
      maximize_browser_window(browser_name)
    end
    @browser
  end

  def self.setup_remote_driver(browser_name)
    browser_name = :firefox if browser_name == :headless
    puts "http://#{ENV['SELENIUM_SERVER']}:4444/wd/hub"
    @browser = Selenium::WebDriver.for :remote,
                                       url:                  "http://#{ENV['SELENIUM_SERVER']}:4444/wd/hub",
                                       desired_capabilities: browser_name
  end

  def self.setup_headless_mode
    @headless = Headless.new dimensions: '1920x1080x24'
    @headless.start
    @browser = Selenium::WebDriver.for :firefox
  end

  def self.tear_down
    @browser.quit
    @headless.destroy if @headless
  end

  def self.maximize_browser_window(browser)
    if OS.host_os == :macosx && browser == :chrome
      position_browser_window_on_top
      max_width, max_height = @browser.execute_script('return [window.screen.availWidth, window.screen.availHeight];')
      @browser.manage.window.resize_to(max_width, max_height)
    else
      @browser.manage.window.maximize
    end
  end

  def self.position_browser_window_on_top
    position = @browser.manage.window.position
    return unless position.x + position.y > 0
    position.x = 0
    position.y = 0
    @browser.manage.window.position = position
  end
end
