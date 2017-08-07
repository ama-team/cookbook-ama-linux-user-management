# frozen_string_literal: true

require_relative '../../mixin/entity'

module AMA
  module Chef
    module User
      module Model
        class PrivateKey
          class Remote
            include Mixin::Entity

            attribute :id, Symbol
            attribute :options, [Hash, K: String, V: [String, Integer]]

            denormalizer_block do |input, type, context, &block|
              input = {} if input.nil?
              if input.is_a?(String) || input.is_a?(Symbol)
                input = { User: input }
              end
              raise "Expected Hash, got #{input.class}" unless input.is_a?(Hash)
              target = {
                options: input[:options] || input['options'] || {},
                id: context.path.current.name
              }
              ['id', :id].each do |key|
                target[:id] = input[key] if input[key]
              end
              input.each do |key, value|
                next if %i[id options].include?(key.to_sym)
                target[:options][key] = value
              end
              block.call(target, type, context)
            end

            def initialize(id = nil)
              @id = id
              @options = {}
            end
          end
        end
      end
    end
  end
end
