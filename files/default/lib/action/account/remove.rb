# frozen_string_literal: true

require_relative '../../action'

module AMA
  module Chef
    module User
      class Action
        module Account
          class Remove < Action
            attr_accessor :account

            # @param [AMA::Chef::User::Model::Account] account
            def initialize(account)
              @account = account
            end

            def apply(resource_factory)
              resource_factory.user @account.id.to_s do
                action :remove
              end
            end

            def to_s
              "account[#{account.id}]:remove"
            end
          end
        end
      end
    end
  end
end
