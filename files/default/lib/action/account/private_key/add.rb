# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

require_relative '../../../action'

module AMA
  module Chef
    module User
      class Action
        module Account
          module PrivateKey
            class Add < Action
              attr_accessor :account
              attr_accessor :key

              # @param [AMA::Chef::User::Model::Account] account
              # @param [AMA::Chef::User::Model::PrivateKey] key
              def initialize(account, key)
                @account = account
                @key = key
              end

              def apply(resource_factory)
                account = @account
                key = @key
                name = "#{account.id}:#{key.owner}:#{key.id}"
                resource_factory.ssh_private_key name do
                  id key.id.to_s
                  user account.id.to_s
                  content key.content.to_s
                  install_public_key key.install_public_key
                  passphrase key.passphrase unless key.passphrase.nil?
                  perform_validation key.validate
                end
              end
            end
          end
        end
      end
    end
  end
end
