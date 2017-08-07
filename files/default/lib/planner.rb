# frozen_string_literal: true

require 'set'

::Dir.glob("#{__dir__}/action/**/*.rb").each do |path|
  require path
end

require_relative 'planner/account'
require_relative 'planner/group'

module AMA
  module Chef
    module User
      # This class is responsible for creating list of actions required for
      # converging from current state to target state
      class Planner
        def initialize
          @accounts = Account.new
          @groups = Group.new
        end

        # @param [AMA::Chef::User::Model::State] current_state
        # @param [AMA::Chef::User::Model::State] desired_state
        def plan(current_state, desired_state)
          plan = [
            *@accounts.plan(current_state.accounts, desired_state.accounts),
            *@groups.plan(current_state.groups, desired_state.groups)
          ]
          plan.each do |action|
            action.class_name = action.class.to_s
          end
          plan
        end
      end
    end
  end
end
