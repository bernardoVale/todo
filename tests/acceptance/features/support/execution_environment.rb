# Available environment variables
# URL - Page to be tested
# PROXY - Set as true to start proxy
# PROXY_PATH - Inform the path were browsermob is installed
# MAC - "/opt/browsermob/bin/browsermob-proxy"
# WINDOWS - "c:\\browsermob-proxy\\bin\\browsermob-proxy.bat"
module ExecutionEnvironment
  def url
    if ENV['URL'].nil?
      message = <<-EOF.gsub(/^\s+/, '')
            The environment variable URL was not defined in command line, you can use:
            cucumber #{ARGV.join(' ')} URL=http://localhost:5000
      EOF
      raise message.red
    end
    ENV['URL']
  end

  def browser
    @browser ||= if OS.mac? && ENV['BROWSER'].nil?
                   puts 'WARNING: Headless mode is not supported on MacOS, setting' \
                                          'to use firefox'.light_red.on_light_yellow
                   :firefox
                 else
                   (ENV['BROWSER'] || 'headless').downcase.to_sym
                 end
  end

  module_function :url
  module_function :browser
end
