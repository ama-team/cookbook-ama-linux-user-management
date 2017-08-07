# frozen_string_literal: true

begin
  defaults = attribute('ama', {})['keys']
  account = defaults['accounts']['master']
  key = account['keys']['default']
rescue StandardError => e
  raise 'Failed to fetch `ama.keys.accounts.master.keys.default` attribute', e
end

control 'ama-linux-user-management.keys' do
  desc '
    Verifies following assumptions:
    - Public keys are installed in authorized_keys if key is present and
      local.enabled is not false
    - Public keys are also installed in impersonated accounts authorized_keys
    - Private keys are installed standalone if key is present and remote.enabled
      is not false
    - Public keys are installed with private keys if present
    - Private keys are not installed for impersonated accounts
    - Keys with local.enabled set to false are not installed in authorized_keys
    - Keys with remote.enabled set to false are not installed standalone
  '

  describe file('/home/master/.ssh/authorized_keys') do
    it { should exist }
    its('content') { should include "ssh-rsa #{key['public']} default" }
    its('content') { should_not include "ssh-rsa #{key['public']} disabled" }
  end

  describe file('/home/master/.ssh/default') do
    it { should exist }
    its('content') { should eq key['private'] }
    its('mode') { should cmp '0600' }
  end

  describe file('/home/master/.ssh/default.pub') do
    it { should exist }
    its('content') { should eq key['public'] }
    its('mode') { should cmp '0644' }
  end

  describe file('/home/master/.ssh/private') do
    it { should exist }
    its('content') { should eq key['private'] }
    its('mode') { should cmp '0600' }
  end

  describe file('/home/master/.ssh/private.pub') do
    it { should_not exist }
  end

  describe file('/home/master/.ssh/disabled') do
    it { should_not exist }
  end

  describe file('/home/master/.ssh/disabled.pub') do
    it { should_not exist }
  end

  describe file('/home/puppet/.ssh/authorized_keys') do
    it { should exist }
    its('content') { should include "ssh-rsa #{key['public']} master.default" }
    its('content') do
      should_not include "ssh-rsa #{key['public']} master.disabled"
    end
  end

  describe file('/home/puppet/.ssh/default') do
    it { should_not exist }
  end

  describe file('/home/puppet/.ssh/default.pub') do
    it { should_not exist }
  end
end
