# frozen_string_literal: true

require_relative '../../privilege'

module AMA
  module Chef
    module User
      module Handler
        class Privilege
          module Group
            # Sudo privilege granter/revoker
            class Sudo < Privilege
              def grant(resource_factory, owner, privilege)
                resource(resource_factory, owner, privilege).action = :install
              end

              def revoke(resource_factory, owner, privilege)
                resource(resource_factory, owner, privilege).action = :remove
              end

              private

              def resource(resource_factory, owner, privilege)
                resource_factory.sudo "group:#{owner.id}" do
                  privilege.options.each do |key, value|
                    if self.class.properties.keys.include?(key)
                      send(key, value)
                    else
                      ::Chef::Log.warn(
                        "Account #{owner.id} sudo privilege " \
                        "has unknown option #{key}"
                      )
                    end
                  end
                  group owner.id.to_s
                end
              end

              # yes, i'm evading excessive line length
              ::AMA::Chef::User::Handler::Privilege.tap do |registry|
                registry.register(:group, :sudo, new)
              end
            end
          end
        end
      end
    end
  end
end
