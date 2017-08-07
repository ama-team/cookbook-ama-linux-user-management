# frozen_string_literal: true

require_relative '../../../../files/default/lib/planner'
require_relative '../../../../files/default/lib/action/group/append_members'
require_relative '../../../../files/default/lib/action/group/set_members'
require_relative '../../../../files/default/lib/action/group/exclude_members'
require_relative '../../../../files/default/lib/action/group/remove'
require_relative '../../../../files/default/lib/action/group/privilege/grant'
require_relative '../../../../files/default/lib/action/group/privilege/revoke'
require_relative '../../../../files/default/lib/action/group/privilege/purge'
require_relative '../../../../files/default/lib/model/group'

klass = ::AMA::Chef::User::Planner::Group
group_klass = ::AMA::Chef::User::Model::Group
append_members_action_klass = ::AMA::Chef::User::Action::Group::AppendMembers
set_members_action_klass = ::AMA::Chef::User::Action::Group::SetMembers
exclude_members_action_klass = ::AMA::Chef::User::Action::Group::ExcludeMembers
remove_action_klass = ::AMA::Chef::User::Action::Group::Remove
action_klasses = [
  append_members_action_klass,
  set_members_action_klass,
  exclude_members_action_klass,
  remove_action_klass
]
privilege_purge_class = ::AMA::Chef::User::Action::Group::Privilege::Purge
privilege_action_classes = %i[Grant Revoke Purge].map do |name|
  ::AMA::Chef::User::Action::Group::Privilege.const_get(name)
end

describe klass do
  describe '#plan' do
    let(:planner) do
      klass.new
    end

    let(:example_1) do
      group_klass.new.tap do |instance|
        instance.id = 'example-1'
        instance.members = Set.new([:root])
        instance.policy = :edit
      end
    end

    let(:example_2) do
      group_klass.new.tap do |instance|
        instance.id = 'example-2'
        instance.members = Set.new([:engineer])
        instance.policy = :manage
      end
    end

    { new: false, existing: true }.each do |type, copy|
      it "creates append members action for #{type} edited group" do |test_case|
        desired_state = { 'example-1': example_1 }
        current_state = copy ? desired_state : {}
        test_case.attach_yaml(current_state, 'current-state')
        test_case.attach_yaml(desired_state, 'target-state')
        actions = planner.plan(current_state, desired_state)
        test_case.attach_yaml(actions, 'actions')
        actions = actions.select do |action|
          action_klasses.include?(action.class)
        end
        test_case.attach_yaml(actions, 'filtered-actions')

        test_case.step 'Validating that only single action is created' do
          expect(actions.length).to eq(1)
        end

        test_case.step 'Validating that correct append members action is created' do
          action = actions[0]
          expect(action).to be_a(append_members_action_klass)
          expect(action.group).to eq(example_1)
        end
      end
    end

    it 'should exclude members action for shrunk edited group' do |test_case|
      member = :tux
      example = example_1.clone
      example.members = example.members.clone
      example.members.add(member)
      current_state = { 'example-1': example }
      desired_state = { 'example-1': example_1 }
      actions = planner.plan(current_state, desired_state).select do |action|
        action.is_a?(exclude_members_action_klass)
      end

      test_case.step 'Validating that only single exclude members action is created' do
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that correct exclude members action is created' do
        action = actions[0]
        expect(action.group.id).to eq(example.id)
        expect(action.members.to_a).to eq([member])
      end
    end

    { new: false, existing: true }.each do |type, copy|
      it "should create set members action for #{type} managed group" do |test_case|
        desired_state = { 'example-2': example_2 }
        current_state = copy ? desired_state : {}
        actions = planner.plan(current_state, desired_state).select do |action|
          action_klasses.include?(action.class)
        end

        test_case.step 'Validating that only single action is created' do
          expect(actions.length).to eq(1)
        end

        test_case.step 'Validating that correct set members action is created' do
          action = actions[0]
          expect(action).to be_a(set_members_action_klass)
          expect(action.group).to eq(example_2)
        end
      end
    end

    it 'should create exclude members action for vanished edited group' do |test_case|
      current_state = { 'example-1': example_1 }
      actions = planner.plan(current_state, {}).select do |action|
        action_klasses.include?(action.class)
      end

      test_case.step 'Validating that only single action is created' do
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that correct exclude members action is created' do
        action = actions[0]
        expect(action).to be_a(exclude_members_action_klass)
        expect(action.group).to eq(example_1)
        expect(action.members).to eq(example_1.members)
      end
    end

    it 'should create remove action for vanished managed group' do |test_case|
      current_state = { 'example-2': example_2 }
      actions = planner.plan(current_state, {}).select do |action|
        action_klasses.include?(action.class)
      end

      test_case.step 'Validating that only single action is created' do
        expect(actions.length).to eq(1)
      end

      test_case.step 'Validating that correct remove action is created' do
        action = actions[0]
        expect(action).to be_a(remove_action_klass)
        expect(action.group).to eq(example_2)
      end
    end

    it 'doesn\'t create privilege actions for non-managed vanished group' do |test_case|
      current_state = { 'example-1': example_1 }
      actions = planner.plan(current_state, {})
      test_case.attach_yaml(actions, 'actions')

      privilege_actions = actions.select do |action|
        privilege_action_classes.include?(action.class)
      end
      test_case.attach_yaml(actions, 'privilege-actions')

      expect(privilege_actions).to eq([])
    end

    it 'creates purge privileges action for managed vanished group' do |test_case|
      current_state = { 'example-2': example_2 }
      actions = planner.plan(current_state, {})
      test_case.attach_yaml(actions, 'actions')

      purge_actions = actions.select do |action|
        action.is_a?(privilege_purge_class)
      end
      test_case.attach_yaml(purge_actions, 'purge-actions')

      expect(purge_actions).not_to be_empty
    end
  end
end
