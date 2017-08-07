# frozen_string_literal: true

require_relative '../../../../lib/model/public_key'

klass = ::AMA::Chef::User::Model::PublicKey

describe klass do
  let(:instance) do
    klass.new.tap do |instance|
      instance.id = :id_rsa
      instance.content = 'aabbccdd'
    end
  end
end
