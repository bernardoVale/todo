#!/usr/bin/env ruby
# Docker script

puts "Ruby version: #{RUBY_VERSION}"

# Colors for log output
GREEN = `tput setaf 2`.freeze
BLUE  = `tput setaf 4`.freeze
CYAN  = `tput setaf 6`.freeze
RESET = `tput sgr0`.freeze

# if no args, exit showing the options
@args = ARGV.clone
if @args.empty?
  puts "
  It will run the cucumber tests, please read the README file for more information
  usage: #{BLUE}docker-compose run --rm cucumber#{CYAN} [options] #{GREEN}[tags|profiles|file]#{RESET}

  Options:
   #{CYAN}-b,--bundle-install     #{RESET}Force to run bundle install, it will run at the first time anyway
   #{CYAN}-n,--node <n>           #{RESET}Works with --parallel, set the number of parallel threads.
   #{CYAN}--parallel              #{RESET}Enable parrallel execution
   #{CYAN}--path <custom path>    #{RESET}Works with --parallel, default to features path
   #{CYAN}--skip-cleanup          #{RESET}Skip the cleanup that removes log files and the target folder
   #{CYAN}-e,--environment <type> #{RESET}Set the acdc enviroment target, can be [dev,qa(default),release,prod]
   #{CYAN}<cucumber options>      #{RESET}Any other cucumber options, some options will not work with --parallel

  Ext Options:
   #{CYAN}--rubocop               #{RESET}Runs the rubocop and nothing else
   #{CYAN}--console               #{RESET}Opens the pry console

  Tags|profiles|file:
   #{GREEN}-t,--tags <arg>         #{RESET}Cucumber tags, works in the same way
   #{GREEN}-p,--profile <arg>      #{RESET}Cucumber profile, works in the same way
   #{GREEN}/path/to/feature[:line] #{RESET}Like cucumber, it will run a specific file

  Examples:
   # runs the tag @user
   #{BLUE}docker-compose run --rm cucumber #{GREEN}-t @user#{RESET}

   # runs the profile ci generating the cucumber report
   #{BLUE}docker-compose run --rm cucumber #{GREEN}-p ci#{RESET}

   # runs the specific scenario from the feature file at the line 23
   #{BLUE}docker-compose run --rm cucumber #{GREEN}features/VerifyBanksList.feature:23#{RESET}

   # runs the tag @user in parallel with 5 threads
   #{BLUE}docker-compose run --rm cucumber #{CYAN}--parallel -n 5 #{GREEN}-t @user#{RESET}

   # checks the code quality with rubocop
   #{BLUE}docker-compose run --rm --no-deps cucumber #{CYAN}--rubocop#{RESET}
  "
  exit 0
end

# Returns true if the given keys were in arguments, it will also remove from the args
def enabled?(*keys)
  exist = @args & keys
  return false if exist.empty?
  @args -= exist
  true
end

# Returns the value from the given keys, it will also remove the key and the value from the args
def custom_value(*keys)
  key = (@args & keys).first
  return unless key
  value = ARVG[@args.index(key) + 1]
  @args -= [key, value]
  value
end

# bundle, set -b to force it, it also will run at the first time
if enabled?('--bundle-install', '-b') || Dir["#{ENV['BUNDLE_PATH']}/ruby/*"].empty?
  puts "#{GREEN}== Looding the bundle of gems =="
  system 'bundle install'
end

# clean logs and target by default, to skip it pass --skip-cleanup
# unless enabled? '--skip-cleanup'
#   puts "#{GREEN}== Removing old logs and tempfiles =="
#   system 'rm -rf logs/* target tmp'
# end

env_target_url =    ENV['URL']
env_target_url ||=  case custom_value '--enviroment', '-e'
                    when /staging|prod/
                      ENV["TODO_#{enviroment_profile.upcase}_URL"]
                    else
                      ENV['TODO_STAGING_URL']
                    end

# This will work with cucumber or with parallel
# Ex:
#     -t @my-tag
#     --parallel -n 5 --path /some/path -t @my-tag
#     --parallel -p layout_check
puts "#{GREEN}== I will execute your command now =="
command = if enabled? '--rubocop'
            {
              base: 'bundle exec rubocop',
              args: @args.join(' ')
            }
          elsif enabled? '--console'
            {
              base: 'bundle exec pry',
              args: @args.join(' ')
            }
          elsif enabled? '--parallel'
            path = custom_value '--path'
            path ||= 'features/'

            nodes = custom_value '-n', '--node'
            nodes = "-n #{nodes}" if nodes

            {
              base: "bundle exec parallel_cucumber #{path} #{nodes} -o",
              args: %s("#{@args.join(' ')}")
            }
          else
            {
              base: 'bundle exec cucumber',
              args: @args.join(' ')
            }
          end

sleep(70)
puts "#{CYAN}URL=#{env_target_url} #{BLUE}#{command[:base]} #{CYAN}#{command[:args]}#{RESET}"
exec "URL=#{env_target_url} #{command[:base]} #{command[:args]}"