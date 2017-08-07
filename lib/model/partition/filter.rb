# frozen_string_literal: true

require_relative '../../mixin/entity'

module AMA
  module Chef
    module User
      module Model
        class Partition
          # Role filter for matching clients that fit into partition
          class Filter
            include Mixin::Entity

            attribute :roles, [Enumerable, T: [Enumerable, T: String]]

            normalizer_block  do |entity, *|
              entity.roles.map do |path|
                path.join('.')
              end .join('+')
            end

            denormalizer_block do |input, *|
              break input if input.is_a?(Filter.class)
              unless input.is_a?(String)
                raise "Expected String, got #{input.class}"
              end
              Filter.new.tap do |instance|
                instance.roles = input.split('+').map do |role|
                  role.split('.').map(&:strip).map(&:to_sym).reject(&:empty?)
                end
              end
            end

            def initialize(roles = [])
              self.roles = roles
            end

            # @param [AMA::Chef::User::Model::Client] account
            def apply(account)
              roles.all? do |role|
                account.roles.contains(role)
              end
            end

            def to_s
              "Partition.Filter `#{normalize}`"
            end
          end
        end
      end
    end
  end
end
