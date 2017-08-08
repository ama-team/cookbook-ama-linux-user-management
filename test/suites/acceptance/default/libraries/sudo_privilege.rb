# frozen_string_literal: true

module SudoPrivilegeBase
  def initialize(name)
    @name = name
    @exists = false
    candidates = %W[#{type}:#{name} #{type}__#{name}]
    candidates.each do |candidate|
      file = inspec.file("/etc/sudoers.d/#{candidate}")
      next unless file.file?
      break @exists = true if file.content.include?("#{prefix}#{name}")
    end
  end

  def prefix
    ''
  end

  def type
    raise 'Abstract method not implemented'
  end

  def exist?
    @exists
  end

  def to_s
    "#{type.capitalize} #{@name} sudo privilege"
  end
end

class UserSudoPrivilege < Inspec.resource(1)
  include SudoPrivilegeBase

  name :user_sudo_privilege

  def type
    'user'
  end
end

class GroupSudoPrivilege < Inspec.resource(1)
  include SudoPrivilegeBase

  name :group_sudo_privilege

  def type
    'group'
  end

  def prefix
    '%'
  end
end
