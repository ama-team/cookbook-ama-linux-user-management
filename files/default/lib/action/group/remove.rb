# frozen_string_literal: true

require_relative '../../action'

module AMA
  module Chef
    module User
      class Action
        module Group
          class Remove < Action
            attr_accessor :group

            # @param [AMA::Chef::User::Model::Group] group
            def initialize(group)
              @group = group
            end

            def apply(resource_factory)
              group = @group
              resource_factory.group "#{@group.id}:remove" do
                group_name group.id.to_s
                action :remove
              end
            end
          end
        end
      end
    end
  end
end
