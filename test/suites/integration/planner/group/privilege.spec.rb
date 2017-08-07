# frozen_string_literal: true

require_relative '../../../../../lib/planner'
require_relative '../../../../../lib/model/privilege'
require_relative '../../../../../lib/model/group'
require_relative '../../../../../lib/action/group/privilege/grant'
require_relative '../../../../../lib/action/group/privilege/revoke'
require_relative '../../../../../lib/action/group/privilege/purge'

klass = ::AMA::Chef::User::Planner::Group::Privilege
privilege_klass = ::AMA::Chef::User::Model::Privilege
group_klass = ::AMA::Chef::User::Model::Group
grant_action_klass = ::AMA::Chef::User::Action::Group::Privilege::Grant
revoke_action_klass = ::AMA::Chef::User::Action::Group::Privilege::Revoke
purge_action_klass = ::AMA::Chef::User::Action::Group::Privilege::Purge

describe klass do
  describe '#plan' do
    let(:planner) do
      klass.new
    end

    let(:group) do
      group_klass.new.tap do |instance|
        instance.id = :wheel
      end
    end

    let(:example_1) do
      privilege_klass.new.tap do |instance|
        instance.type = :sudo
        instance.options = { nopasswd: true }
      end
    end

    let(:example_2) do
      privilege_klass.new.tap do |instance|
        instance.type = :mount
        instance.options = { paths: ['/media'] }
      end
    end

    { new: false, existing: true }.each do |type, copy|
      it "should create grant action for #{type} privilege" do |test_case|
        desired_state = { 'example-1': example_1 }
        current_state = copy ? desired_state : {}
        actions = planner.plan(group, current_state, desired_state)

        test_case.step 'Validating that exactly one action is created' do
          expect(actions.length).to eq(1)
        end

        test_case.step 'Validating that correct grant action is created' do
          action = actions[0]
          expect(action).to be_a(grant_action_klass)
          expect(action.group).to eq(group)
          expect(action.privilege).to eq(example_1)
        end
      end
    end

    it 'should create revoke action for vanished privilege' do |test_case|
      current_state = { 'example-1': example_1 }
      actions = planner.plan(group, current_state, {}).select do |action|
        action.is_a?(revoke_action_klass)
      end

      test_case.step 'Validating that exactly one revoke action is created' do
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that correct revoke action is created' do
        action = actions[0]
        expect(action).to be_a(revoke_action_klass)
        expect(action.group).to eq(group)
        expect(action.privilege).to eq(example_1)
      end
    end

    it 'should create purge action for no privileges desired' do |test_case|
      actions = planner.plan(group, {}, {})

      test_case.step 'Validating that exactly one action is created' do
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that correct purge action is created' do
        action = actions[0]
        expect(action).to be_a(purge_action_klass)
        expect(action.group).to eq(group)
      end
    end
  end
end
