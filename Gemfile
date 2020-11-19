source "https://rubygems.org"

gem "fastlane"
gem "rest-client"
gem "danger-gitlab"
gem "danger-xcov"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
