# frozen_string_literal: true

require_relative '../../mixin/entity'
require_relative '../policy'

module AMA
  module Chef
    module User
      module Model
        class Partition
          # Determines how user and group accounts will be treated
          class PolicyGroup
            include Mixin::Entity

            attribute :account, Policy, default: Policy::EDIT
            attribute :group, Policy, default: Policy::EDIT

            DEFAULT = new.tap do |instance|
              instance.account = Policy::EDIT
              instance.group = Policy::EDIT
            end

            def to_s
              "Partition.Policy {account: #{account}, group: #{group}}"
            end
          end
        end
      end
    end
  end
end
