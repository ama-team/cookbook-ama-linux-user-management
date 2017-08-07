# frozen_string_literal: true

require_relative '../../../../files/default/lib/model/group'

klass = ::AMA::Chef::User::Model::Group

describe klass do
  describe '#==' do
    let(:group) do
      klass.new(:sudo).tap do |state|
        state.privileges = {}
        state.members = Set.new(%i[bill philip])
        state.policy = :manage
      end
    end

    it 'should return true if contents are identical' do |test_case|
      normalized = AMA::Entity::Mapper.normalize(group)
      mirror = AMA::Entity::Mapper.map(normalized, klass)
      test_case.attach_yaml(group, :subject)
      test_case.attach_yaml(mirror, :other)
      expect(group).to eq(mirror)
    end

    it 'should return false if contents are not identical' do |test_case|
      normalized = AMA::Entity::Mapper.normalize(group)
      other = AMA::Entity::Mapper.map(normalized, klass)
      other.id = :visudo
      test_case.attach_yaml(group, :subject)
      test_case.attach_yaml(other, :other)
      expect(group).not_to eq(other)
    end

    it "should return false if compared with anything other than #{klass}" do
      expect(group).not_to eq(32)
    end
  end
end
