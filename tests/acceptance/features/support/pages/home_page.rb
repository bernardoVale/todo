# Maps the home page after login
class HomePage
  include PageObject

  page_url ExecutionEnvironment.url

  div            :greeting, class: 'page-header'

  def initialize_page
    wait_until do
      greeting_element.visible?
    end
  end
end
