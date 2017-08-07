# frozen_string_literal: true

require_relative '../../../../../lib/planner'
require_relative '../../../../../lib/action/account/privilege/grant'
require_relative '../../../../../lib/action/account/privilege/revoke'
require_relative '../../../../../lib/action/account/privilege/purge'
require_relative '../../../../../lib/model/privilege'
require_relative '../../../../../lib/model/account'

klass = ::AMA::Chef::User::Planner::Account::Privilege
grant_action_klass = ::AMA::Chef::User::Action::Account::Privilege::Grant
revoke_action_klass = ::AMA::Chef::User::Action::Account::Privilege::Revoke
purge_action_klass = ::AMA::Chef::User::Action::Account::Privilege::Purge
privilege_klass = ::AMA::Chef::User::Model::Privilege
account_klass = ::AMA::Chef::User::Model::Account

describe klass do
  describe '#plan' do
    let(:planner) do
      klass.new
    end

    let(:account) do
      account_klass.new.tap do |instance|
        instance.id = :root
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

    it 'should create grant action for new privilege' do |test_case|
      desired_state = { 'example-1': example_1 }
      actions = planner.plan(account, {}, desired_state)

      test_case.step 'Validating that exactly one action is created' do
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that correct grant action is created' do
        action = actions[0]
        expect(action).to be_a(grant_action_klass)
        expect(action.account).to eq(account)
        expect(action.privilege).to eq(example_1)
      end
    end

    it 'should create grant action for existing privilege' do |test_case|
      current_state = desired_state = { 'example-1': example_1 }
      actions = planner.plan(account, current_state, desired_state)

      test_case.step 'Validating that exactly one action is created' do
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that correct grant action is created' do
        action = actions[0]
        expect(action).to be_a(grant_action_klass)
        expect(action.account).to eq(account)
        expect(action.privilege).to eq(example_1)
      end
    end

    it 'should create revoke action for vanished privilege' do |test_case|
      desired_state = { 'example-1': example_1 }
      actions = planner.plan(account, desired_state, {}).select do |action|
        action.is_a?(revoke_action_klass)
      end

      test_case.step 'Validating that exactly one revoke action is created' do
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that correct revoke action is created' do
        action = actions[0]
        expect(action).to be_a(revoke_action_klass)
        expect(action.account).to eq(account)
        expect(action.privilege).to eq(example_1)
      end
    end

    it 'should create purge action for no privileges desired' do |test_case|
      actions = planner.plan(account, {}, {})

      test_case.step 'Validating that exactly one action is created' do
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that correct purge action is created' do
        action = actions[0]
        expect(action).to be_a(purge_action_klass)
        expect(action.account).to eq(account)
      end
    end
  end
end
