# frozen_string_literal: true

require_relative '../../../../lib/planner'
require_relative '../../../../lib/action/account/create'
require_relative '../../../../lib/action/account/remove'
require_relative '../../../../lib/action/account/privilege/grant'
require_relative '../../../../lib/action/account/privilege/revoke'
require_relative '../../../../lib/action/account/privilege/purge'
require_relative '../../../../lib/model/account'

klass = ::AMA::Chef::User::Planner::Account
create_action_klass = ::AMA::Chef::User::Action::Account::Create
remove_action_klass = ::AMA::Chef::User::Action::Account::Remove
action_klasses = [create_action_klass, remove_action_klass]
privilege_purge_class = ::AMA::Chef::User::Action::Account::Privilege::Purge
privilege_action_classes = %i[Grant Revoke Purge].map do |name|
  ::AMA::Chef::User::Action::Account::Privilege.const_get(name)
end
account_klass = ::AMA::Chef::User::Model::Account

describe klass do
  describe '#plan' do
    let(:planner) do
      klass.new
    end

    let(:example_1) do
      account_klass.new.tap do |instance|
        instance.id = 'example-1'
        instance.policy = :edit
      end
    end

    let(:example_2) do
      account_klass.new.tap do |instance|
        instance.id = 'example-2'
        instance.policy = :manage
      end
    end

    it 'should create create action for new account' do |test_case|
      desired_state = { 'example-1': example_1 }
      actions = planner.plan({}, desired_state).select do |action|
        action_klasses.include?(action.class)
      end

      test_case.step 'Validating that exactly one action is created' do
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that correct create action is created' do
        action = actions[0]
        expect(action).to be_a(create_action_klass)
        expect(action.account).to eq(example_1)
      end
    end

    it 'should create create action for existing account' do |test_case|
      current_state = desired_state = { 'example-1': example_1 }
      actions = planner.plan(current_state, desired_state).select do |action|
        action_klasses.include?(action.class)
      end

      test_case.step 'Validating that exactly one action is created' do
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that correct create action is created' do
        action = actions[0]
        expect(action).to be_a(create_action_klass)
        expect(action.account).to eq(example_1)
      end
    end

    it 'should not create remove action for vanished edited account' do |test_case|
      current_state = { 'example-1': example_1 }
      actions = planner.plan(current_state, {})
      test_case.attach_yaml(actions, :actions)
      actions = actions.select do |action|
        action_klasses.include?(action.class)
      end

      test_case.step 'Validating that no account actions are created' do
        expect(actions.length).to eq(0)
      end
    end

    it 'should create remove action for vanished managed account' do |test_case|
      current_state = { 'example-2': example_2 }
      actions = planner.plan(current_state, {})
      test_case.attach_yaml(actions, :actions)
      actions = actions.select do |action|
        action_klasses.include?(action.class)
      end

      test_case.step 'Validating that exactly one account action is created' do
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that correct remove action is created' do
        action = actions[0]
        expect(action).to be_a(remove_action_klass)
        expect(action.account).to eq(example_2)
      end
    end

    it 'doesn\'t create privilege actions for non-managed vanished account' do
      current_state = { 'example-1': example_1 }
      actions = planner.plan(current_state, {})
      privilege_actions = actions.select do |action|
        privilege_action_classes.include?(action.class)
      end
      expect(privilege_actions).to eq([])
    end

    it 'creates purge privileges action for managed vanished account' do
      current_state = { 'example-2': example_2 }
      actions = planner.plan(current_state, {})
      purge_actions = actions.select do |action|
        action.is_a?(privilege_purge_class)
      end
      expect(purge_actions).not_to be_empty
    end
  end
end
