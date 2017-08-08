# frozen_string_literal: true

class PrivateKey < Inspec.resource(1)
  name :private_key

  def initialize(definition)
    @definition = definition
    @username, @owner, @name, @passphrase = definition.split(':')
    @user = inspec.user(@username)
    @path = "#{@user.home}/.ssh/#{@name}"
    @file = inspec.file(@path)
  end

  def content
    @file.content if @file.file?
  end

  def exist?
    @file.file?
  end

  def to_s
    "PrivateKey #{@definition}"
  end
end
