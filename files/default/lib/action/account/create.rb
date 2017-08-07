# frozen_string_literal: true

require_relative '../../action'

module AMA
  module Chef
    module User
      class Action
        module Account
          class Create < Action
            attr_accessor :account

            # @param [AMA::Chef::User::Model::Account] account
            def initialize(account)
              @account = account
              super()
            end

            def apply(resource_factory)
              resource_factory.user @account.id
            end
          end
        end
      end
    end
  end
end
