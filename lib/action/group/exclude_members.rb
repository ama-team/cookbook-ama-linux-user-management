# frozen_string_literal: true

require_relative '../../action'

module AMA
  module Chef
    module User
      class Action
        module Group
          class ExcludeMembers < Action
            attr_accessor :group
            attr_accessor :members

            # @param [AMA::Chef::User::Model::Group] group
            # @param [Enumerable] members
            def initialize(group, members)
              @group = group
              @members = members
            end

            def apply(resource_factory)
              members = @members
              group = @group
              resource_factory.group "#{group.id}:members:remove" do
                group_name group.id.to_s
                excluded_members members.to_a
                append true
              end
            end
          end
        end
      end
    end
  end
end
