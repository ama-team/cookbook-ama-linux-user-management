# frozen_string_literal: true

require_relative '../../../../../../files/default/lib/planner'
require_relative '../../../../../../files/default/lib/model/private_key'
require_relative '../../../../../../files/default/lib/action/account/private_key/remote/add'
require_relative '../../../../../../files/default/lib/action/account/private_key/remote/remove'
require_relative '../../../../../../files/default/lib/model/account'

klass = ::AMA::Chef::User::Planner::Account::PrivateKey::Remote
remote_klass = ::AMA::Chef::User::Model::PrivateKey::Remote
add_klass = ::AMA::Chef::User::Action::Account::PrivateKey::Remote::Add
remove_klass = ::AMA::Chef::User::Action::Account::PrivateKey::Remote::Remove
purge_klass = ::AMA::Chef::User::Action::Account::PrivateKey::Remote::Purge
key_klass = ::AMA::Chef::User::Model::PrivateKey
account_klass = ::AMA::Chef::User::Model::Account

describe klass do
  describe '#plan' do
    let(:key) do
      key_klass.new.tap do |instance|
        instance.id = :default
        instance.owner = :engineer
      end
    end

    let(:account) do
      account_klass.new.tap do |instance|
        instance.id = :root
      end
    end

    let(:remote_1) do
      remote_klass.new.tap do |instance|
        instance.id = 'bitbucket.org'
        instance.options = { User: 'git', Port: 22 }
      end
    end

    let(:remote_2) do
      remote_klass.new.tap do |instance|
        instance.id = 'internal.company'
        instance.options = { User: 'bob', Port: 11_522 }
      end
    end

    let(:planner) do
      ::AMA::Chef::User::Planner::Account::PrivateKey::Remote.new
    end

    it 'should create one add action for one fresh remote' do |test_case|
      current_state = {}
      desired_state = { 'bitbucket.org': remote_1 }
      actions = planner.plan(account, key, current_state, desired_state)

      test_case.step 'Validating that exactly one action is generated' do
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that correct action is generated' do
        action = actions[0]
        expect(action).to be_a(add_klass)
        expect(action.account).to eq(account)
        expect(action.private_key).to eq(key)
        expect(action.remote).to eq(remote_1)
      end
    end

    it 'should create one action per already existing and vanished remote' do |test_case|
      current_state = { 'bitbucket.org': remote_1, 'github.com': remote_2 }
      desired_state = { 'bitbucket.org': remote_1 }
      actions = planner.plan(account, key, current_state, desired_state)

      test_case.step 'Validating that exactly two actions are generated' do
        expect(actions.length).to eq(2)
      end

      add_actions = actions.select { |action| action.is_a?(add_klass) }
      test_case.step 'Validating that one add action is generated' do
        expect(add_actions.length).to eq(1)
      end

      add_action = add_actions[0]
      test_case.step 'Validating that correct add action is generated' do
        expect(add_action.account).to eq(account)
        expect(add_action.private_key).to eq(key)
        expect(add_action.remote).to eq(remote_1)
      end

      remove_actions = actions.select { |action| action.is_a?(remove_klass) }
      test_case.step 'Validating that exactly one remove action is generated' do
        expect(remove_actions.length).to eq(1)
      end

      remove_action = remove_actions[0]
      test_case.step 'Validating that correct remove action is generated' do
        expect(remove_action.account).to eq(account)
        expect(remove_action.private_key).to eq(key)
        expect(remove_action.remote).to eq(remote_2)
      end
    end

    it 'should create purge action when no more remotes left' do |test_case|
      current_state = {}
      desired_state = {}
      actions = planner.plan(account, key, current_state, desired_state)

      test_case.step 'Validating that exactly one action is created' do
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that created action is valid purge action' do
        action = actions[0]
        expect(action).to be_a(purge_klass)
        expect(action.account).to eq(account)
        expect(action.private_key).to eq(key)
      end
    end
  end
end
