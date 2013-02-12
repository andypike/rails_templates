# $ psql postgres
#   # create user blog with password '' CREATEDB;
#   # \q
# $ rvm gemset use blog --create
# $ gem install rails --no-ri --no-rdoc
# $ rails new blog -d postgresql --skip-test-unit -m rails_templates/andy.rb
# $ cd blog
# $ rake

def erb_to_haml(erb_file)
  haml_file = erb_file.gsub(/erb/, 'haml')
  run "html2haml #{erb_file} #{haml_file}"
  remove_file erb_file
end

gem 'haml-rails'
gem 'simple_form'
gem 'strong_parameters'

gem_group :assets do
  gem 'bootstrap-sass'
  gem 'compass-rails'
end

gem_group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'shoulda'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'factory_girl_rails'
  gem 'letter_opener'
  gem 'better_errors'
  gem 'binding_of_caller'
end

run 'bundle install'
run 'gem install hpricot'
run 'gem install ruby_parser'

generate 'rspec:install'
generate 'simple_form:install --bootstrap'

append_file ".rspec", "--format documentation"
create_file ".rvmrc", "rvm gemset use #{@app_name} --create"

generate :controller, "pages home"
route "root to: 'pages\#home'"
remove_file "public/index.html"

remove_file 'README.rdoc'
file 'README.md', <<-CODE
Setup
-----

Install RVM and Ruby 1.9.3+
  
$ git clone REPO_LOCATION_HERE
$ cd #{app_name}
$ bundle
$ psql
  # create user #{app_name} with password '' CREATEDB;
  # \\q
$ cp config/example.database.yml config/database.yml
$ rake db:setup
$ rails s

Running Specs
-------------

$ rake
CODE

erb_to_haml "app/views/layouts/application.html.erb"
remove_file "app/assets/javascripts/pages.js.coffee"
append_file "app/assets/javascripts/application.js", "//= require bootstrap"
remove_file "app/assets/stylesheets/application.css"
remove_dir  "spec/helpers"
remove_dir  "spec/views"
remove_dir  "spec/controllers"

file "app/assets/javascripts/#{@app_name}.js.coffee", <<-CODE
$ ->
  # Do something on load
CODE

file "app/assets/stylesheets/layout.css.scss", <<-CODE
body {
  background: white;
}
CODE

file "app/assets/stylesheets/application.css.scss", <<-CODE
@import "bootstrap";
@import "layout";
CODE

file 'spec/spec_helper.rb', <<-CODE
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rails'
require 'capybara/rspec'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.fixture_path = "\#{::Rails.root}/spec/fixtures"
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
end
CODE

file 'spec/support/database_cleaner.rb', <<-CODE
RSpec.configure do |config|
  config.use_transactional_fixtures = false
  
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
  
  config.before :each do
    DatabaseCleaner.start
  end
  
  config.after :each do
    DatabaseCleaner.clean
  end
end
CODE

application <<-CODE
config.generators do |g|
  g.fixture_replacement :factory_girl
end
CODE

file "spec/features/pages_spec.rb", <<-CODE
require 'spec_helper'

describe "viewing general site pages" do
  it "shows the homepage" do
    visit root_url
    
    page.should have_content 'Pages#home'
  end
end
CODE

rake "db:create"
rake "db:migrate"

git :init
append_file ".gitignore", "config/database.yml"
run "cp config/database.yml config/example.database.yml"
git add: ".", commit: "-m 'initial commit'"

