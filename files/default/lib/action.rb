# frozen_string_literal: true

module AMA
  module Chef
    module User
      # Action represents single action required to be taken to converge
      # system into target state. Actions are created during planning phase
      # and then run by feeding in current resource they are called from within
      class Action
        attr_accessor :class_name

        # rubocop:disable Lint/UnusedMethodArgument
        def apply(resource)
          raise 'Abstract method left behind'
        end
        # rubocop:enable Lint/UnusedMethodArgument

        protected

        def noop
          ::Chef::Log.debug('Noop action')
        end
      end
    end
  end
end
