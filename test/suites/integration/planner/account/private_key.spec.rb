# frozen_string_literal: true

require_relative '../../../../../lib/planner'
require_relative '../../../../../lib/action/account/private_key/add'
require_relative '../../../../../lib/action/account/private_key/remove'
require_relative '../../../../../lib/action/account/private_key/purge'
require_relative '../../../../../lib/model/private_key'
require_relative '../../../../../lib/model/account'

klass = ::AMA::Chef::User::Planner::Account::PrivateKey
entity_klass = ::AMA::Chef::User::Model::PrivateKey
account_klass = ::AMA::Chef::User::Model::Account
add_action_klass = ::AMA::Chef::User::Action::Account::PrivateKey::Add
remove_action_klass = ::AMA::Chef::User::Action::Account::PrivateKey::Remove
purge_action_klass = ::AMA::Chef::User::Action::Account::PrivateKey::Purge
action_klasses = [add_action_klass, remove_action_klass, purge_action_klass]

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
      entity_klass.new.tap do |instance|
        instance.id = 'example-1'
        instance.owner = 'engineer'
        instance.content = 'aabbccdd'
        instance.type = 'ssh-rsa'
      end
    end

    let(:example_2) do
      entity_klass.new.tap do |instance|
        instance.id = 'example-2'
        instance.owner = 'cto'
        instance.content = 'ddbbccaa'
        instance.type = 'ssh-rsa'
      end
    end

    it 'should create action for introduced key' do |test_case|
      current_state = {}
      desired_state = { engineer: { 'example-1': example_1 } }
      actions = planner.plan(account, current_state, desired_state)
      actions = actions.select do |action|
        action_klasses.include?(action.class)
      end

      test_case.step 'Validating that exactly one action was created' do
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that correct add-action was returned' do
        action = actions[0]
        expect(action).to be_a(add_action_klass)
        expect(action.key).to eq(example_1)
        expect(action.account).to eq(account)
      end
    end

    it 'should repeat add action for existing key' do |test_case|
      current_state = { engineer: { 'example-1': example_1 } }
      desired_state = { engineer: { 'example-1': example_1 } }
      actions = planner.plan(account, current_state, desired_state)
      actions = actions.select do |action|
        action_klasses.include?(action.class)
      end

      test_case.step 'Validating that exactly one action was created' do
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that correct add-action was returned' do
        action = actions[0]
        expect(action).to be_a(add_action_klass)
        expect(action.key).to eq(example_1)
        expect(action.account).to eq(account)
      end
    end

    it 'should create remove action for vanished key' do |test_case|
      current_state = { engineer: { 'example-1': example_1 } }
      desired_state = {}
      actions = planner.plan(account, current_state, desired_state)
      actions = actions.select do |action|
        action.is_a?(remove_action_klass)
      end

      test_case.step 'Validating that exactly one remove action was created' do
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that correct remove-action was returned' do
        action = actions[0]
        expect(action).to be_a(remove_action_klass)
        expect(action.key).to eq(example_1)
        expect(action.account).to eq(account)
      end
    end

    it 'should create purge action when no keys are expected' do |test_case|
      actions = planner.plan(account, {}, {})

      test_case.step 'Validating that exactly one action was created' do
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that correct purge-action was returned' do
        action = actions[0]
        expect(action).to be_a(purge_action_klass)
        expect(action.account).to eq(account)
      end
    end
  end
end
