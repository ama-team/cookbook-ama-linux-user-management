# frozen_string_literal: true

require 'pathname'
require 'ama-entity-mapper'

require_relative 'run_history/run'
require_relative 'loader'

module AMA
  module Chef
    module User
      module Test
        module Fixture
          class RunHistory
            include Entity::Mapper::DSL

            attribute :id, String, nullable: true
            attribute :name, String, nullable: true
            attribute :runs, [Enumerable, T: Run]
            attribute :functional, TrueClass, FalseClass, default: true
            attribute :acceptance, TrueClass, FalseClass, default: false

            def name
              @name || @id.gsub(%r{[\-\/]+}, ' ')
            end

            def runs=(runs)
              runs ||= []
              iterator = 0..runs.length - 1
              @runs = iterator.map do |index|
                runs[index].tap do |run|
                  run.id = index if run.respond_to?(:id)
                end
              end
            end

            def to_s
              "Run History '#{name}'"
            end

            Loader.fuse(self, 'run-history')
          end
        end
      end
    end
  end
end
