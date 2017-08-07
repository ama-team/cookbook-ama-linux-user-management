# frozen_string_literal: true

namespace :lint do
  task :foodcritic do
    sh 'bundle exec foodcritic .'
  end

  task :rubocop do
    sh 'bundle exec rubocop'
  end

  namespace :rubocop do
    task :html do
      sh 'bundle exec rubocop --format html -o test/report/rubocop/index.html'
    end
  end

  task html: %i[foodcritic rubocop:html]

  task all: %i[foodcritic rubocop]
end

task lint: %i[lint:all]
