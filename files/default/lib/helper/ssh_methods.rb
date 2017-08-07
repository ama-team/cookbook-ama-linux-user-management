# frozen_string_literal: true

module AMA
  module Chef
    module User
      module Helper
        # Handful of methods that may be helpful for SSH file-related work
        module SSHMethods
          def home_directory(account_id)
            Etc.getpwnam(account_id.to_s).dir
          rescue ArgumentError
            "/home/#{account_id}"
          end

          def ssh_directory(account_id)
            "#{home_directory(account_id)}/.ssh"
          end
        end
      end
    end
  end
end
