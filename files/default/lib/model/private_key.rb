# frozen_string_literal: true

require 'digest'

require_relative '../mixin/entity'
require_relative 'private_key/remote'

module AMA
  module Chef
    module User
      module Model
        class PrivateKey
          include Mixin::Entity

          attribute :id, Symbol
          attribute :owner, Symbol
          attribute :type, Symbol, nullable: true
          attribute :content, String, sensitive: true, nullable: true
          attribute :digest, String
          attribute :public_key, String, sensitive: true, nullable: true
          attribute :passphrase, String, sensitive: true, nullable: true
          attribute :remotes, [Hash, K: Symbol, V: Remote], default: {}
          attribute :validate, TrueClass, FalseClass, default: true
          attribute :install_public_key, TrueClass, FalseClass, default: false

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

          def content=(content)
            return @content = @digest = nil if content.nil?
            @digest = Digest::MD5.hexdigest(content)
            @content = content
          end

          def ==(other)
            return false unless other.is_a?(self.class)
            @id == other.id && @owner == other.owner && @digest == other.digest
          end

          def merge(other)
            @public_key = other.public_key if other.public_key
            @remotes.merge!(other.remotes)
            @validate = true if other.validate
            @install_public_key = true if other.install_public_key
          end
        end
      end
    end
  end
end
