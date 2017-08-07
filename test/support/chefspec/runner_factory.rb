# frozen_string_literal: true

require 'logger'

require_relative '../../../lib/state/persister'
require_relative '../../../lib/state/builder'
require_relative 'solo_runner'

module AMA
  module Chef
    module User
      module Test
        module ChefSpec
          class RunnerFactory
            INSTANCE = new

            def initialize(configuration = {})
              @configuration = configuration
            end

            def create(example:, group:, attributes:, data_bags:)
              options = {
                example: example,
                group: group,
                attributes: attributes,
                data_bags: data_bags
              }
              config = @configuration.merge(options)
              runner = SoloRunner.new(config)
              yield(runner) if block_given?
              runner
            end

            def stateful(example:, group:, state:, clients:, partitions:)
              attributes = partitions
              %w[partitions user ama].each do |segment|
                attributes = { segment => attributes }
              end
              options = {
                example: example,
                group: group,
                attributes: attributes,
                data_bags:  { 'clients' => clients }
              }
              create(options) do |runner|
                persister = State::Persister.new(runner.node)
                persister.persist('default', state)
              end
            end

            class << self
              RunnerFactory.instance_methods(false).each do |method|
                define_method(method) do |*args|
                  RunnerFactory::INSTANCE.send(method, *args)
                end
              end
            end
          end
        end
      end
    end
  end
end
