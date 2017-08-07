# frozen_string_literal: true

require_relative '../../../action'
require_relative '../../..//handler/privilege'

module AMA
  module Chef
    module User
      class Action
        module Account
          module Privilege
            class Grant < Action
              attr_accessor :account
              attr_accessor :privilege

              # @param [AMA::Chef::User::Model::Account] account
              # @param [AMA::Chef::User::Model::Privilege] privilege
              def initialize(account, privilege)
                @account = account
                @privilege = privilege
              end

              def apply(resource_factory)
                registry = ::AMA::Chef::User::Handler::Privilege
                handler = registry.retrieve!(:account, @privilege.type)
                handler.grant(resource_factory, @account, @privilege)
              end
            end
          end
        end
      end
    end
  end
end
