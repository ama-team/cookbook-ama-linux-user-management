# frozen_string_literal: true

require_relative '../../../../files/default/lib/model/account'

klass = AMA::Chef::User::Model::Account

describe klass do
  describe '#==' do
    subject = klass.new.tap do |account|
      account.id = :bill
      account.privileges = {}
      account.public_keys = {}
      account.private_keys = {}
      account.policy = :manage
    end
    normalized = AMA::Entity::Mapper.normalize(subject)

    it 'should return true if contents are identical' do |test_case|
      mirror = AMA::Entity::Mapper.map(normalized, klass)
      test_case.attach_yaml(subject, :subject)
      test_case.attach_yaml(mirror, :mirror)
      expect(subject).to eq(mirror)
    end

    it 'should return false if contents are not identical' do |test_case|
      other = AMA::Entity::Mapper.map(normalized, klass)
      other.policy = :none
      test_case.attach_yaml(subject, :subject)
      test_case.attach_yaml(other, :other)
      expect(subject).not_to eq(other)
    end

    it 'should return false if compared with anything other than UserState' do
      expect(subject).not_to eq(32)
    end
  end
end
