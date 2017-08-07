# frozen_string_literal: true

require_relative '../../action'

module AMA
  module Chef
    module User
      class Action
        module Group
          class SetMembers < Action
            attr_accessor :group

            # @param [AMA::Chef::User::Model::Group] group
            def initialize(group)
              @group = group
            end

            def apply(resource_factory)
              group = @group
              resource_factory.group "#{group.id}:members:set" do
                group_name group.id.to_s
                members group.members.to_a
                append false
              end
            end
          end
        end
      end
    end
  end
end
