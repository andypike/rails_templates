Andy's Rails Template
=====================

I create rails apps now and again and I like my stack, so here is a template that makes it easier.

The basic stack includes (amongst other things):

* haml
* simple_form
* twitter bootstrap
* strong_parameters
* compass
* rspec
* capybara
* factory_girl
* postgres
* rvm

To create a new rails project (called blog in this case):

$ psql postgres
  # create user blog with password '' CREATEDB;
  # \q
$ rvm gemset use blog --create
$ gem install rails --no-ri --no-rdoc
$ rails new blog -d postgresql --skip-test-unit -m rails_templates/andy.rb
$ cd blog
$ rake

This should result in one passing spec.

Enjoy!