# frozen_string_literal: true

require 'rspec/core/rake_task'

root = ::File.dirname(__dir__)

namespace :test do
  task :clean do
    %w[metadata report].each do |folder|
      FileUtils.rm_rf(::File.join(root, 'test', folder))
    end
  end

  task :report do
    sh 'allure generate --clean -o test/report/allure test/metadata/allure/** test/metadata/junit/**'
  end

  %i[unit integration functional].each do |type|
    RSpec::Core::RakeTask.new(type) do |task|
      opts = [
        '--default-path test/suites',
        "--require #{type}",
        "--pattern #{type}/**/*.spec.rb"
      ]
      task.rspec_opts = opts.join(' ')
    end
  end

  task :all, [:platform] => %i[unit integration functional acceptance]

  [:unit, :integration, :functional, acceptance: [:platform]].each do |type|
    args = []
    unless type.is_a?(Symbol)
      args = type.values.first
      type = type.keys.first
    end
    namespace type do
      task :'with-report', args do |_, arguments|
        Rake::Task[:'test:clean'].invoke
        begin
          Rake::Task[:"test:#{type}"].invoke(*arguments.to_a)
        rescue StandardError => e
          puts 'FAILED'
          raise e
        ensure
          Rake::Task[:'test:report'].invoke
        end
        puts 'PASSED'
      end
    end
  end
end

task test: %i[test:all]
