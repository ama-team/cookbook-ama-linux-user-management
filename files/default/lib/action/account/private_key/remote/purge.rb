# frozen_string_literal: true

require_relative '../../../../action'

module AMA
  module Chef
    module User
      class Action
        module Account
          module PrivateKey
            module Remote
              class Purge < Action
                attr_accessor :account
                attr_accessor :private_key

                # @param [AMA::Chef::User::Model::Account] account
                # @param [AMA::Chef::User::Model::PrivateKey] private_key
                def initialize(account, private_key)
                  @account = account
                  @private_key = private_key
                end

                def apply(*)
                  noop
                end
              end
            end
          end
        end
      end
    end
  end
end
