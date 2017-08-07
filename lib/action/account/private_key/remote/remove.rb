# frozen_string_literal: true

require_relative '../../../../action'

module AMA
  module Chef
    module User
      class Action
        module Account
          module PrivateKey
            module Remote
              class Remove < Action
                attr_accessor :account
                attr_accessor :private_key
                attr_accessor :remote

                # @param [AMA::Chef::User::Model::Account] account
                # @param [AMA::Chef::User::Model::PrivateKey] private_key
                # @param [AMA::Chef::User::Model::PrivateKey::Remote] remote
                def initialize(account, private_key, remote)
                  @account = account
                  @private_key = private_key
                  @remote = remote
                end

                def apply(resource_factory)
                  account = @account
                  key = @private_key
                  remote = @remote
                  name = "#{account.id}:#{key.owner}:#{key.id}:#{remote.id}"
                  resource_factory.ssh_config name do
                    host remote.id.to_s
                    user account.id.to_s
                    action :remove
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
