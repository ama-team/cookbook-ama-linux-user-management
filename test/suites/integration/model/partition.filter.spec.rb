# frozen_string_literal: true

require_relative '../../../../lib/model/partition'
require_relative '../../../../lib/model/client'
require_relative '../../../../lib/model/client/role_tree'

klass = AMA::Chef::User::Model::Partition::Filter
client_klass = AMA::Chef::User::Model::Client
role_tree_class = AMA::Chef::User::Model::Client::RoleTree

describe klass do
  describe '#apply' do
    php_developer = client_klass.new.tap do |account|
      account.id = :php_developer
      account.roles = role_tree_class.new(developer: { php: nil })
    end
    java_developer = client_klass.new.tap do |account|
      account.id = :java_developer
      account.roles = role_tree_class.new(developer: { java: nil })
    end
    polyglot = client_klass.new.tap do |account|
      account.id = :polyglot
      roles = { developer: { java: nil, php: nil, ruby: nil } }
      account.roles = role_tree_class.new(roles)
    end
    engineer = client_klass.new.tap do |account|
      account.id = :engineer
      roles = { ops: { lead: nil }, qa: { middle: nil } }
      account.roles = role_tree_class.new(roles)
    end

    it 'should match single-level query' do
      filter = AMA::Entity::Mapper.map('developer', klass)
      expect(filter.apply(php_developer)).to be_truthy
      expect(filter.apply(engineer)).to be_falsey
    end

    it 'should match exact role specification' do
      filter = AMA::Entity::Mapper.map('developer.php', klass)
      expect(filter.apply(php_developer)).to be_truthy
      expect(filter.apply(java_developer)).to be_falsey
    end

    it 'should match and-query' do
      filter = AMA::Entity::Mapper.map('developer.java + developer.php', klass)
      expect(filter.apply(php_developer)).to be_falsey
      expect(filter.apply(java_developer)).to be_falsey
      expect(filter.apply(polyglot)).to be_truthy
    end
  end
end
