# frozen_string_literal: true

require 'digest'

require_relative '../mixin/entity'

module AMA
  module Chef
    module User
      module Model
        class PublicKey
          include Mixin::Entity

          attribute :owner, Symbol
          attribute :id, Symbol
          attribute :type, Symbol, default: :'ssh-rsa'
          attribute :content, String, sensitive: true, nullable: true
          attribute :digest, String
          attribute :validate, TrueClass, FalseClass, default: true

          denormalizer_block do |input, type, context, &block|
            input = { content: input } if input.is_a?(String)
            raise "Hash expected, got #{input.class}" unless input.is_a?(Hash)
            { id: -1, owner: -3 }.each do |key, index|
              if [key, key.to_s].none? { |v| input.key?(v) }
                segment = context.path.segments[index]
                input[key] = segment.name unless segment.nil?
              end
            end
            block.call(input, type, context)
          end

          normalizer_block do |entity, type, context, &block|
            normalized = block.call(entity, type, context)
            if context.include_sensitive_attributes
              normalized[:content] = entity.content
            end
            normalized
          end

          def full_id
            raise 'Missing owner' unless @owner
            raise 'Missing id' unless @id
            "#{@owner}:#{@id}"
          end

          def content=(content)
            @digest = content.nil? ? nil : Digest::MD5.hexdigest(content)
            @content = content
          end

          def to_s
            "PublicKey #{owner}:#{id}"
          end
        end
      end
    end
  end
end
