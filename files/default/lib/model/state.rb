# frozen_string_literal: true

require_relative '../mixin/entity'

require_relative 'account'
require_relative 'group'

module AMA
  module Chef
    module User
      module Model
        # Represents complete node state
        class State
          include Mixin::Entity

          # !@attribute groups
          #   @return [Hash{Symbol, Group}]
          attribute :groups, [Hash, K: Symbol, V: Group], default: {}
          # !@attribute accounts
          #   @return [Hash{Symbol, Account}]
          attribute :accounts, [Hash, K: Symbol, V: Account], default: {}
          # !@attribute version
          #   @return [Integer]
          attribute :version, Integer, default: 1

          def initialize
            @groups = {}
            @accounts = {}
            @version = 1
          end

          # @return [AMA::Chef::User::Model::Account]
          def account!(id)
            id = id.to_sym
            unless accounts[id]
              accounts[id] = Account.new
              accounts[id].id = id
              accounts[id].policy = Policy::NONE
            end
            account(id)
          end

          # @return [AMA::Chef::User::Model::Account]
          def account(id)
            accounts[id.to_sym]
          end

          # @return [AMA::Chef::User::Model::Group]
          def group!(id)
            id = id.to_sym
            unless groups[id]
              groups[id] = Group.new
              groups[id].id = id
            end
            group(id)
          end

          # @return [AMA::Chef::User::Model::Group]
          def group(id)
            groups[id.to_sym]
          end
        end
      end
    end
  end
end
