# frozen_string_literal: true

require 'yaml'

require_relative '../../../files/default/lib/planner'
require_relative '../../../files/default/lib/model/state'
require_relative '../../support/fixture/state'

klass = ::AMA::Chef::User::Planner
state_klass = ::AMA::Chef::User::Model::State
fixture_klass = ::AMA::Chef::User::Test::Fixture::State

describe klass do
  describe '#plan' do
    let(:planner) do
      klass.new
    end

    it 'should provide empty array of actions for empty input' do |test_case|
      expect(planner.plan(state_klass.new, state_klass.new)).to eq([])
    end

    fixture_klass.each do |fixture|
      it "should not emit null actions for fixture state #{fixture.name}" do |test_case|
        test_case.attach_yaml(fixture.state, :state)
        test_case.step 'building the state' do
          actions = planner.plan(state_klass.new, fixture.state)
          test_case.attach_yaml(actions, :actions)
          actions.each do |action|
            expect(action).not_to be_nil
          end
        end
        test_case.step 'destroying the state' do
          actions = planner.plan(fixture.state, state_klass.new)
          test_case.attach_yaml(actions, :actions)
          actions.each do |action|
            expect(action).not_to be_nil
          end
        end
      end
    end
  end
end
