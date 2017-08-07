# frozen_string_literal: true

require_relative '../../../action'

module AMA
  module Chef
    module User
      class Action
        module Group
          module Privilege
            class Purge < Action
              attr_accessor :group

              # @param [AMA::Chef::User::Model::Group] group
              def initialize(group)
                @group = group
              end

              def apply(*)
                noop
              end
            end
          end
        end
      end
    end
  end
end
