# frozen_string_literal: true

require 'yaml'
require 'tempfile'
require_relative '../../../../files/default/lib/state/builder'
require_relative '../../../../files/default/lib/model/client'
require_relative '../../../../files/default/lib/model/partition'
require_relative '../../../../files/default/lib/model/account'
require_relative '../../../../files/default/lib/model/group'
require_relative '../../../../files/default/lib/model/state'
require_relative '../../../support/fixture/state'

klass = AMA::Chef::User::State::Builder
fixture_class = AMA::Chef::User::Test::Fixture::State

describe klass do
  let(:state_builder) do
    klass.new
  end

  describe '#build' do
    fixture_class.each do |fixture|
      it "should match expectations in scenario '#{fixture.name}'" do |test_case|
        state = state_builder.build(fixture.clients, fixture.partitions)
        expectation = fixture.state

        test_case.attach_yaml(fixture.clients, :clients)
        test_case.attach_yaml(fixture.partitions, :partitions)
        test_case.attach_yaml(state, :state)
        test_case.attach_yaml(expectation, :expectation)

        account_names = state.accounts.keys | expectation.accounts.keys
        account_names.each do |name|
          test_case.step "Validating `#{name}` account equality" do
            actual = state.accounts[name]
            expected = expectation.accounts[name]
            test_case.attach_yaml(actual, :actual)
            test_case.attach_yaml(expected, :expectation)
            expect(actual).to eq(expected)
          end
        end

        group_names = state.groups.keys | expectation.groups.keys
        group_names.each do |name|
          test_case.step "Validating `#{name}` group equality" do
            actual = state.groups[name]
            expected = expectation.groups[name]
            test_case.attach_yaml(actual, :actual)
            test_case.attach_yaml(expected, :expectation)
            expect(actual).to eq(expected)
          end
        end

        test_case.step 'Validating whole state equality' do
          expect(state).to eq(expectation)
        end
      end
    end
  end
end
