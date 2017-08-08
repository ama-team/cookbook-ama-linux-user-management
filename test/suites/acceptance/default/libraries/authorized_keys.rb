# frozen_string_literal: true

class AuthorizedKeys < Inspec.resource(1)
  name :authorized_keys

  def initialize(user)
    @user = inspec.user(user)
    file = inspec.file(path)
    @content = file.file? ? file.content : ''
  end

  def include?(needle)
    @content.include?(needle)
  end

  def path
    "#{@user.home}/.ssh/authorized_keys"
  end

  def to_s
    "User #{@user.username} authorized keys (#{path})"
  end
end
