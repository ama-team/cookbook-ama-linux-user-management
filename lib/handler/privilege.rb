# frozen_string_literal: true

# rubocop:disable Lint/UnusedMethodArgument

require_relative '../exception/missing_handler_exception'

module AMA
  module Chef
    module User
      module Handler
        # Privilege handler base / registry
        class Privilege
          def grant(resource_factory, owner, privilege)
            abstract_method_protector
          end

          def revoke(resource_factory, owner, privilege)
            abstract_method_protector
          end

          private

          def abstract_method_protector
            raise 'Abstract method hasn\'t been implemented'
          end

          class << self
            def register(domain, type, handler)
              domain = domain.to_sym
              type = type.to_sym
              registry[domain] = {} unless registry[domain]
              registry[domain][type] = handler
            end

            def retrieve(domain, type)
              domain = domain.to_sym
              type = type.to_sym
              registry[domain] && registry[domain][type]
            end

            def retrieve!(domain, type)
              handler = retrieve(domain, type)
              return handler if handler
              message = "No privilege handler with type #{type} " \
                "has been found in domain #{domain}"
              raise Exception::MissingHandlerException, message
            end

            private

            def registry
              @registry = {} unless @registry
              @registry
            end
          end
        end
      end
    end
  end
end
