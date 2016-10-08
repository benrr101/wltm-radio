source 'http://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.3.18', '< 0.5'
# Use Puma as the app server
gem 'puma', '~> 3.0'

############################################################################
# Asset Pipeline Components

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# As much as I hate it, I'm going to use bootstrap because it's fast
gem 'bootstrap-sass'
gem 'autoprefixer-rails'  # Prereq for ^
gem 'bootswatch-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Adding support for typescript in the asset pipeline
gem 'typescript-rails'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Use knockout.js as the client-side framework
gem 'knockoutjs-rails'

############################################################################
# Application Components

# This project uses rufus-scheduler to do background jobs
gem 'rufus-scheduler'

# To interface with MPD we use ruby-mpd
gem 'ruby-mpd'

# Gems to access status of the various components
gem 'sys-filesystem'
gem 'sys-proctable'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
