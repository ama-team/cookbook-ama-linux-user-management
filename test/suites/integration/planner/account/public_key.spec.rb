# frozen_string_literal: true

require_relative '../../../../../files/default/lib/planner'
require_relative '../../../../../files/default/lib/model/public_key'
require_relative '../../../../../files/default/lib/model/account'
require_relative '../../../../../files/default/lib/action/account/public_key/add'
require_relative '../../../../../files/default/lib/action/account/public_key/remove'

klass = ::AMA::Chef::User::Planner::Account::PublicKey
add_klass = ::AMA::Chef::User::Action::Account::PublicKey::Add
remove_klass = ::AMA::Chef::User::Action::Account::PublicKey::Remove
purge_klass = ::AMA::Chef::User::Action::Account::PublicKey::Purge
key_klass = ::AMA::Chef::User::Model::PublicKey
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

    let(:key_1) do
      key_klass.new.tap do |key|
        key.id = 'key-1'
        key.type = 'ssh-rsa'
        key.owner = 'donor-1'
        key.content = 'content'
      end
    end

    let(:key_2) do
      key_klass.new.tap do |key|
        key.id = 'key-2'
        key.type = 'ssh-rsa'
        key.owner = 'donor-2'
        key.content = 'content'
      end
    end

    it 'should return add action on new single key' do |test_case|
      current_state = {}
      desired_state = { 'donor-1': { 'key-1': key_1 } }
      actions = planner.plan(account, current_state, desired_state)

      test_case.step 'Validating that only one action is generated' do
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that generated action is an expected add' do
        action = actions[0]
        expect(action).to be_a(add_klass)
        expect(action.account).to eq(account)
        expect(action.key).to eq(key_1)
      end
    end

    it 'should return add action on repeated single key' do |test_case|
      current_state = { 'donor-1': { 'key-1': key_1 } }
      desired_state = { 'donor-1': { 'key-1': key_1 } }
      actions = planner.plan(account, current_state, desired_state)

      test_case.step 'Validating that only one action is generated' do
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that generated action is an expected add' do
        action = actions[0]
        expect(action).to be_a(add_klass)
        expect(action.account).to eq(account)
        expect(action.key).to eq(key_1)
      end
    end

    it 'should return remove action on single disappeared key' do |test_case|
      current_state = {
        'donor-1': { 'key-1': key_1 },
        'donor-2': { 'key-2': key_2 }
      }
      desired_state = { 'donor-1': { 'key-1': key_1 } }
      actions = planner.plan(account, current_state, desired_state)

      test_case.step 'Validating that two actions were generated' do
        expect(actions.length).to eq(2)
      end

      test_case.step 'Validating that exactly one action is a remove-action' do
        actions = actions.select { |action| action.is_a?(remove_klass) }
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that remove action specifies correct key' do
        action = actions[0]
        expect(action.account).to eq(account)
        expect(action.key).to eq(key_2)
      end
    end

    it 'should return add and remove action if new key was added and old one key was omitted' do |test_case|
      current_state = { 'donor-1': { 'key-1': key_1 } }
      desired_state = { 'donor-2': { 'key-2': key_2 } }
      actions = planner.plan(account, current_state, desired_state)

      test_case.step 'Validating that exactly two actions are created' do
        expect(actions.length).to eq(2)
      end

      add_actions = actions.select { |action| action.is_a?(add_klass) }
      test_case.step 'Validating that exactly one add action was created' do
        expect(add_actions.length).to eq(1)
      end

      test_case.step 'Validating that add action specifies correct key' do
        add_action = add_actions[0]
        expect(add_action.account).to eq(account)
        expect(add_action.key).to eq(key_2)
      end

      remove_actions = actions.select { |action| action.is_a?(remove_klass) }
      test_case.step 'Validating that exactly one action is a remove-action' do
        expect(remove_actions.length).to eq(1)
      end

      test_case.step 'Validating that remove action specifies correct key' do
        remove_action = remove_actions[0]
        expect(remove_action.account).to eq(account)
        expect(remove_action.key).to eq(key_1)
      end
    end

    it 'should provide purge action if no keys are desired' do |test_case|
      current_state = { 'donor-1': { 'key-1': key_1 } }
      desired_state = {}
      actions = planner.plan(account, current_state, desired_state)

      test_case.step 'Validating that exactly two actions were created' do
        expect(actions.length).to eq(2)
      end

      remove_actions = actions.select { |action| action.is_a?(remove_klass) }
      test_case.step 'Validating that exactly one remove action was created' do
        expect(remove_actions.length).to eq(1)
      end

      test_case.step 'Validating that remove action specifies correct key' do
        remove_action = remove_actions[0]
        expect(remove_action.account).to eq(account)
        expect(remove_action.key).to eq(key_1)
      end

      purge_actions = actions.select { |action| action.is_a?(purge_klass) }
      test_case.step 'Validating that exactly one purge action was created' do
        expect(purge_actions.length).to eq(1)
      end

      test_case.step 'Validating that purge action specifies correct account' do
        purge_action = purge_actions[0]
        expect(purge_action.account).to eq(account)
      end
    end
  end
end
