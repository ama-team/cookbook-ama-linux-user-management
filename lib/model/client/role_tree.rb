# frozen_string_literal: true

require_relative '../../mixin/entity'

module AMA
  module Chef
    module User
      module Model
        class Client
          # Internal structure for client roles
          class RoleTree
            include Mixin::Entity

            attribute :root, [Hash, K: Symbol, V: [:*, NilClass]], default: {}

            normalizer_block do |entity, *|
              entity.root
            end

            denormalizer_block do |input, *|
              break RoleTree.new(input) if input.is_a?(Hash)
              raise "Expected Hash, received #{input.class}"
            end

            def initialize(root = {})
              @root = root
            end

            def contains(path)
              cursor = @root
              path.each do |segment|
                return false unless cursor.respond_to?(:key?)
                candidates = [segment.to_s, segment.to_sym]
                next_segment = candidates.find do |candidate|
                  cursor.key?(candidate)
                end
                return false unless next_segment
                cursor = cursor[next_segment]
              end
              true
            end
          end
        end
      end
    end
  end
end
