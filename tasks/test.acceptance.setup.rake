# frozen_string_literal: true

require 'yaml'
require 'fileutils'

require_relative '../test/support/fixture/run_history'

root = ::File.dirname(__dir__)
cookbook_path = "#{root}/test/support/cookbooks/alum-acceptance"

namespace :test do
  namespace :acceptance do
    namespace :setup do
      task :kitchen do
        puts 'Rendering .kitchen.yml'
        template = "#{root}/.kitchen.base.yml"
        target = "#{root}/.kitchen.yml"

        raw = ::IO.read(template)
        structure = ::YAML.safe_load(raw, [], [], true)
        filter = :acceptance.to_proc
        histories = ::AMA::Chef::User::Test::Fixture::RunHistory.select(&filter)
        suites = histories.map do |history|
          attributes = { history: history.id }
          {
            name: history.id.gsub('/', '-'),
            run_list: ['alum-acceptance'],
            attributes: attributes,
            verifier: {
              inspec_tests: [
                {
                  name: history.name,
                  path: 'test/suites/acceptance/default'
                }
              ],
              attributes: attributes
            }
          }
        end
        structure[:suites] = suites

        # poor man's symbol to string conversion
        structure = YAML.safe_load(YAML.to_json(structure))
        content = YAML.dump(structure)
        ::IO.write(target, content)
      end

      task :gems do
        %i[libraries/loader.rb files/default/vendor].each do |path|
          target = "#{cookbook_path}/#{path}"
          source = "#{root}/#{path}"
          FileUtils.mkdir_p(::File.dirname(target))
          sh "cp -Tr '#{source}' '#{target}'"
        end
      end

      task :cookbook do
        %i[fixture support/fixture].each do |path|
          source = "#{root}/test/#{path}"
          target = "#{cookbook_path}/files/default/lib/#{path}"
          FileUtils.mkdir_p(::File.dirname(target))
          sh "cp -Tr '#{source}' '#{target}'"
        end
      end

      task all: %i[kitchen gems cookbook]
    end
    task setup: %i[setup:all]
  end
end
