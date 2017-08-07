# frozen_string_literal: true

require_relative '../../../action'
require_relative '../../../handler/privilege'

module AMA
  module Chef
    module User
      class Action
        module Group
          module Privilege
            class Revoke < Action
              attr_accessor :group
              attr_accessor :privilege

              # @param [AMA::Chef::User::Model::Group] group
              # @param [AMA::Chef::User::Model::Privilege] privilege
              def initialize(group, privilege)
                @group = group
                @privilege = privilege
              end

              def apply(resource_factory)
                registry = ::AMA::Chef::User::Handler::Privilege
                handler = registry.retrieve!(:group, @privilege.type)
                handler.revoke(resource_factory, @group, @privilege)
              end
            end
          end
        end
      end
    end
  end
end
