# frozen_string_literal: true

require_relative '../mixin/entity'

module AMA
  module Chef
    module User
      module Model
        class Privilege
          include Mixin::Entity

          attribute :type, Symbol
          attribute :options, [Hash, K: Symbol, V: [:*, NilClass]], default: {}

          denormalizer_block do |input, type, context, &block|
            input = {} unless input.is_a?(Hash)
            target = {}
            keys = ['type', 'options', :type, :options]
            keys.each do |key|
              target[key.to_sym] = input[key] if input[key]
            end
            target[:options] = {} unless target[:options].is_a?(Hash)
            input.each do |key, value|
              next if keys.include?(key)
              target[:options][key] = value
            end
            target[:type] = context.path.current.name unless target.key?(:type)
            block.call(target, type, context)
          end

          def to_s
            "Privilege :#{type}"
          end
        end
      end
    end
  end
end
