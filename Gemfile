# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in drying_rails.gemspec
gemspec

gem 'rake', '~> 13.0'
gem 'ustruct', '~> 0.1', github: 'MaTsou/ustruct'

group :development, :test do
  gem 'minitest', '~> 5.24'
  gem 'rubocop-minitest'
  gem 'rubocop-rake'
end
