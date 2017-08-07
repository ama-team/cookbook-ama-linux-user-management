# frozen_string_literal: true

require_relative '../support/rspec/configurer'

configurer = ::AMA::Chef::User::Test::RSpec::Configurer
configurer.configure(:functional, chefspec: true)
