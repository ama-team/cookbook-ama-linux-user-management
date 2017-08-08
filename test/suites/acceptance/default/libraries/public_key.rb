# frozen_string_literal: true

class PublicKey < Inspec.resource(1)
  name :public_key

  def initialize(definition)
    @definition = definition
    @username, @owner, @name = definition.split(':')
    @user = inspec.user(@username)
    @path = "#{@user.home}/.ssh/#{@name}.pub"
    @file = inspec.file(@path)
  end

  def content
    @file.content if @file.file?
  end

  def exist?
    @file.file?
  end

  def to_s
    "public key #{@definition}"
  end
end
