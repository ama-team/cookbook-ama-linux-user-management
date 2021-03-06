# frozen_string_literal: true

require_relative '../../../../action'
require_relative '../../../../helper/ssh_methods'

module AMA
  module Chef
    module User
      class Action
        module Account
          module PrivateKey
            module Remote
              class Add < Action
                include Helper::SSHMethods

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
                  path = "#{ssh_directory(@account.id)}/#{@private_key.id}"
                  options = @remote.options.merge('IdentityFile' => path)
                  account = @account
                  key = @private_key
                  remote = @remote
                  name = "#{account.id}:#{key.owner}:#{key.id}:#{remote.id}"
                  resource_factory.ssh_config name do
                    user account.id.to_s
                    host remote.id.to_s
                    options options
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
