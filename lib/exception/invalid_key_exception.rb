# frozen_string_literal: true

module AMA
  module Chef
    module User
      module Exception
        # Designed to be thrown whenever invalid key is supplied
        class InvalidKeyException < ArgumentError
        end
      end
    end
  end
end
