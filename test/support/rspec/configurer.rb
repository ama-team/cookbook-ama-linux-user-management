# frozen_string_literal: true

require 'logger'
require 'rspec'
require 'allure-rspec'
require 'chefspec'
require 'chefspec/berkshelf'
require 'coveralls'
require 'pathname'

require_relative '../allure/dsl'

module AMA
  module Chef
    module User
      module Test
        module RSpec
          # RSpec configuration facility
          class Configurer
            class << self
              def configure(suite, coverage: true, chefspec: false)
                ::RSpec.configure do |config|
                  config.pattern = '**/*.spec.rb'
                  configure_allure(config, suite) unless ENV['DISABLE_ALLURE']
                  configure_chefspec(config, suite) if chefspec
                  configure_coverage(suite) if coverage
                  load_files
                end
              end

              private

              def project_root
                (0..2).reduce(__dir__) do |path|
                  ::File.dirname(path)
                end
              end

              def configure_allure(rspec_config, suite)
                rspec_config.include ::AllureRSpec::Adaptor
                ::AllureRSpec.configure do |allure_config|
                  allure_config.logging_level = ::Logger::WARN
                  directory = "#{project_root}/test/metadata/allure/#{suite}"
                  allure_config.output_dir = directory
                end
                ::AllureRSpec::DSL::Example.send(:include, Test::Allure::DSL)
              end

              def configure_chefspec(rspec_config, _suite)
                cookbook_path = "#{project_root}/test/support/cookbooks"
                rspec_config.cookbook_path = cookbook_path
                rspec_config.platform = 'ubuntu'
                rspec_config.version = '16.04'
                return unless ENV['CHEF_LOG_LEVEL']
                rspec_config.log_level = ENV['CHEF_LOG_LEVEL'].downcase.to_sym
              end

              def configure_coverage(suite)
                root = Pathname.new(project_root)
                Coveralls.wear_merged! do
                  command_name "rspec:#{suite}"
                  coverage_dir 'test/metadata/coverage'
                  self.formatters = [
                    SimpleCov::Formatter::HTMLFormatter,
                    Coveralls::SimpleCov::Formatter
                  ]
                  add_filter do |file|
                    path = Pathname.new(file.filename).relative_path_from(root)
                    path.to_s !~ /^lib/
                  end
                end
              end

              def load_files
                pattern = ::File.join(project_root, 'lib', '**', '*.rb')
                Dir.glob(pattern).each do |path|
                  require(path.sub(/\.rb$/, ''))
                end
              end
            end
          end
        end
      end
    end
  end
end
