# frozen_string_literal: true

module AMA
  module Chef
    module User
      module Exception
        # Thrown in case privilege handler isn't found
        class MissingHandlerException < ArgumentError
        end
      end
    end
  end
end
