# frozen_string_literal: true

require 'yaml'
require 'ama-entity-mapper'

require_relative 'loader'
require_relative '../../../lib/model/client'
require_relative '../../../lib/model/partition'
require_relative '../../../lib/model/state'

module AMA
  module Chef
    module User
      module Test
        module Fixture
          class State
            include Entity::Mapper::DSL

            attribute :id, String, nullable: true
            attribute :name, String, nullable: true
            attribute :clients, [Hash, K: Symbol, V: Model::Client]
            attribute :partitions, [Hash, K: Symbol, V: Model::Partition]
            attribute :state, Model::State

            def initialize(id = nil)
              @id = id
              @clients = {}
              @partitions = {}
              @state = Model::State.new
            end

            def name
              @name || @id.gsub(%r{[\-\/]+}, ' ')
            end

            Loader.fuse(self, 'state')
          end
        end
      end
    end
  end
end
