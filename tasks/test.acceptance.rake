# frozen_string_literal: true

require 'yaml'
require 'fileutils'
require 'nokogiri'
require 'pathname'

require_relative '../libraries/loader'
require_relative '../test/support/cookbooks/alum-testing/files/default/lib/fixture/run_history'

root = ::File.dirname(__dir__)

namespace :test do
  task :acceptance, [:platform] do |_, arguments|
    command = 'bundle exec kitchen test'
    command += ' ' + arguments[:platform] if arguments[:platform]
    command += ' --concurrency'
    sh command
    Rake::Task[:'test:acceptance:allurize'].invoke
  end

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
            name: history.id.tr('/', '-'),
            run_list: ['alum-testing::acceptance'],
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

      task all: %i[kitchen]
    end
    task setup: %i[setup:all]

    task :allurize do
      Dir.glob("#{root}/test/metadata/junit/**/*.xml").each do |raw_path|
        path = Pathname.new(raw_path)
        name = path.basename.to_s.gsub(/^TEST\-|\.xml$/, '')
        target = path.dirname.join("TEST-#{name}.xml")
        chunks = name.split('-on-').unshift('Acceptance').map do |chunk|
          chunk.tr('-', ' ').capitalize
        end
        suite = chunks.join(' :: ')
        document = Nokogiri::XML(File.open(path))
        document.root = document.at_xpath('//testsuite')
        document.xpath('//testcase').each do |element|
          element['classname'] = suite unless element['classname']
        end
        File.write(target, document.to_xml)
      end
    end
  end
end
