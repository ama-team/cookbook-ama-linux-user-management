# frozen_string_literal: true

require 'ama-entity-mapper'

require_relative 'loader'

module AMA
  module Chef
    module User
      module Test
        module Fixture
          class Entity
            include AMA::Entity::Mapper::DSL

            attribute :id, String, nullable: true
            attribute :name, String, nullable: true
            attribute :model, String
            attribute :input, :*, nullable: true
            attribute :expectation, :*

            def initialize(id = nil)
              @id = id
            end

            def name
              @name || @id.gsub(%r{[\-\/]+}, ' ')
            end

            Loader.fuse(self, 'entity')
          end
        end
      end
    end
  end
end
