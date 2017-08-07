# frozen_string_literal: true

require 'yaml'
require 'logger'
require 'time'

require_relative '../../../../support/chefspec/runner_factory'
require_relative '../../../../support/fixture/run_history'
require_relative '../../../../../files/default/lib/model/state'
require_relative '../../../../../files/default/lib/planner'
require_relative '../../../../../files/default/lib/state/builder'
require_relative '../../../../../files/default/lib/state/persister'

recipe = 'alum-functional::accumulator'

describe 'recipe' do
  describe recipe do
    let(:state_builder) do
      ::AMA::Chef::User::State::Builder.new
    end

    let(:planner) do
      ::AMA::Chef::User::Planner.new
    end

    let(:runner_factory) do
      resources = %w[
        ama_linux_user_management
        ama_linux_user_management_accumulator
      ]
      options = { step_into: resources, log_level: :debug }
      ::AMA::Chef::User::Test::ChefSpec::RunnerFactory.new(options)
    end

    ::AMA::Chef::User::Test::Fixture::RunHistory.each do |history|
      next unless history.functional

      it "should comply with history '#{history.name}'" do |test_case|
        # Tell CI we're still alive
        puts "#{Time.now.utc.iso8601} Validating history #{history.name}"

        current_state = ::AMA::Chef::User::Model::State.new

        history.runs.each do |run|
          run_id = run.id + 1
          step_name = lambda do |name|
            "run ##{run_id}: #{name}"
          end
          desired_state = state_builder.build(run.clients, run.partitions)
          actions = planner.plan(current_state, desired_state)
          converge = nil

          test_case.step step_name.call('converge') do
            options = {
              example: test_case,
              group: self,
              state: current_state,
              clients: run.clients,
              partitions: run.partitions
            }
            runner = runner_factory.stateful(options)
            test_case.attach_yaml(current_state, 'current-state')
            test_case.attach_yaml(desired_state, 'target-state')
            test_case.attach_yaml(actions, 'actions')
            converge = runner.converge(recipe)
            runner.close
          end

          run.resource_matchers.each do |matcher|
            if matcher.action.eql?(true)
              name = 'any action taken'
            elsif matcher.action.eql?(false)
              name = 'no action taken'
            else
              name = "#{matcher.action} action"
            end
            resource_name = "#{matcher.type}[#{matcher.name}]"
            step = step_name.call("validating #{resource_name} :#{name}")
            test_case.step step do
              test_case.attach_yaml(matcher, 'matcher')
              if matcher.action.nil?
                subject = converge.send(matcher.type, matcher.name)
                rspec_matcher = do_nothing
              else
                matcher_name = "#{matcher.action}_#{matcher.type}"
                rspec_matcher = send(matcher_name, matcher.name)
                unless matcher.properties.empty?
                  rspec_matcher = rspec_matcher.with(matcher.properties)
                end
                subject = converge
              end
              expectation = matcher.inverse ? :not_to : :to
              expect(subject).send(expectation, rspec_matcher)
            end
          end
          current_state = desired_state
        end
      end
    end
  end
end
