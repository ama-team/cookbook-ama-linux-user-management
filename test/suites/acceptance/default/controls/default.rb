# frozen_string_literal: true

require_relative '../../../../support/cookbooks/alum-testing/libraries/loader'
require_relative '../../../../support/cookbooks/alum-testing/files/default/lib/fixture/run_history'

id = attribute('history', {})
history = ::AMA::Chef::User::Test::Fixture::RunHistory.single(id)
run = history.runs.last

control "ama-linux-user-management history #{history.name} compliance" do
  run.assertions.each do |resource_type, resources|
    resources.each do |resource_id, nested_assertions|
      describe send(resource_type, resource_id.to_s) do
        nested_assertions.each do |property, assertions|
          target = property == :it ? [:it] : [:its, property.to_s]
          assertions.content.each do |assertion|
            acceptor = :should
            matcher = assertion.content
            if assertion.content.first.to_s == 'not'
              acceptor = :should_not
              matcher.shift
            end
            send(*target) do
              send(acceptor, send(*matcher))
            end
          end
        end
      end
    end
  end
end
