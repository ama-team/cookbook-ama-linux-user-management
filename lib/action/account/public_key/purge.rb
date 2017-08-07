# frozen_string_literal: true

require_relative '../../../action'
require_relative '../../../helper/ssh_methods'

module AMA
  module Chef
    module User
      class Action
        module Account
          module PublicKey
            class Purge < Action
              include Helper::SSHMethods

              attr_accessor :account

              # @param [AMA::Chef::User::Model::Account] account
              def initialize(account)
                @account = account
              end

              def apply(resource_factory)
                resource_id = "#{ssh_directory(@account.id)}/authorized_keys"
                resource_factory.file resource_id do
                  action :delete
                end
              end
            end
          end
        end
      end
    end
  end
end
