# frozen_string_literal: true

class SshConfigEntry < Inspec.resource(1)
  name :ssh_config_entry

  def initialize(definition)
    @username, @host = definition.split(':')
    @user = inspec.user(@username)
    @path = "#{@user.home}/.ssh/config"
    @file = inspec.file(@path)
    content = @file.file? ? @file.content : ''
    @entries = parse(content)
    @entry = @entries[@host]
  end

  def method_missing(name)
    return @entry[name.to_s] if @entry
    super
  end

  def respond_to_missing?(name, *)
    @entry && @entry.key?(name)
  end

  def exist?
    !@entry.nil?
  end

  def parse(content)
    chunks = content.split('Host ')
    chunks.shift
    chunks.each_with_object({}) do |chunk, container|
      lines = chunk.lines.map(&:strip)
      host = lines.shift
      options = lines.each_with_object({}) do |line, carrier|
        key, value = line.split(/\s/, 2)
        carrier[key.downcase] = value
      end
      container[host] ||= {}
      container[host].merge!(options)
    end
  end

  def to_s
    "#{@username} ssh config for #{@host}"
  end
end
