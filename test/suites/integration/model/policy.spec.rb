# frozen_string_literal: true

require_relative '../../../../files/default/lib/model/policy'

klass = ::AMA::Chef::User::Model::Policy

describe klass do
  describe '#<=>' do
    it 'should turn out that :none is < :edit' do
      expect(klass::NONE).to be < klass::EDIT
    end
  end
end
