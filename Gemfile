source 'https://rubygems.org'

# Specify your gem's dependencies in git_context.gemspec
gemspec

group :development do
  gem 'guard'
  gem 'guard-rspec', require: false
  gem 'lefthook'
  gem 'rubocop', require: false
end

group :development, :test do
  gem 'rake', '~> 12.0'
  gem 'rspec', '~> 3.0'
  gem 'rspec_junit_formatter'
  gem 'simplecov', require: false
end

group :test do
  gem 'codecov', require: false
end
