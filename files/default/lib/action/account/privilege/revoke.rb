# frozen_string_literal: true

require_relative '../../../action'

module AMA
  module Chef
    module User
      class Action
        module Account
          module Privilege
            class Revoke < Action
              attr_accessor :account
              attr_accessor :privilege

              # @param [AMA::Chef::User::Model::Account] account
              # @param [AMA::Chef::User::Model::Privilege] type
              def initialize(account, privilege)
                @account = account
                @privilege = privilege
              end

              def apply(resource_factory)
                registry = ::AMA::Chef::User::Handler::Privilege
                handler = registry.retrieve!(:account, @privilege.type)
                handler.revoke(resource_factory, @account, @privilege)
              end
            end
          end
        end
      end
    end
  end
end
