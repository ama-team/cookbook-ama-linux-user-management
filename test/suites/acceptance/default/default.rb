# frozen_string_literal: true

require_relative '../../../../test/support/fixture/run_history'

id = attribute('history', {})
history = ::AMA::Chef::User::Test::Fixture::RunHistory.single(id)
run = history.runs.last

control "ama-linux-user-management history #{history.name} compliance" do
  def execute(assertion, &block)
    target = assertion.property == :it ? [:it] : [:its, assertion.property]
    send(*target, &block)
  end
  run.assertions.each do |resource_type, resources|
    resources.each do |resource_id, nested_assertions|
      describe send(resource_type, resource_id) do
        nested_assertions.each do |property, assertions|
          target = property == :it ? [:it] : [:its, property]
          send(*target) do
            assertions.each do |assertion|
              send(assertion.content)
            end
          end
        end
      end
    end
  end
end
