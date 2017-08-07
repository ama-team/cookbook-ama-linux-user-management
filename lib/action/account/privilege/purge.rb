# frozen_string_literal: true

require_relative '../../../action'

module AMA
  module Chef
    module User
      class Action
        module Account
          module Privilege
            class Purge < Action
              attr_accessor :account

              # @param [AMA::Chef::User::Model::Account] account
              def initialize(account)
                @account = account
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
