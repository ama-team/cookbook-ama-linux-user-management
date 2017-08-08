# Cookbook ama-linux-user-management

[![Chef cookbook](https://img.shields.io/cookbook/v/ama-linux-user-management.svg?style=flat-square)](https://supermarket.chef.io/cookbooks/ama-linux-user-management)
[![CircleCI branch](https://img.shields.io/circleci/project/github/ama-team/cookbook-linux-user-management/master.svg?style=flat-square)](https://circleci.com/gh/ama-team/cookbook-linux-user-management/tree/master)
[![Coveralls branch](https://img.shields.io/coveralls/ama-team/cookbook-linux-user-management/master.svg?style=flat-square)](https://coveralls.io/github/ama-team/cookbook-linux-user-management?branch=master)
[![Scrutinizer](https://img.shields.io/scrutinizer/g/ama-team/cookbook-linux-user-management/master.svg?style=flat-square)](https://scrutinizer-ci.com/g/ama-team/cookbook-linux-user-management?branch=master)
[![Code Climate](https://img.shields.io/codeclimate/github/ama-team/cookbook-linux-user-management.svg?style=flat-square)](https://codeclimate.com/github/ama-team/cookbook-linux-user-management)

This Chef cookbook is aimed to simplify the process of mapping real
people (or bots) and their machine credentials to corresponding linux 
user accounts, groups, sudo superpowers and stuff.

Cookbook takes quite opinionated approach that may dramatically change
in next releases. Until v1.0, every minor release may introduce 
breaking changes.

## How does it work?

In a nutshell, end user of this cookbook specifies *clients* 
(represents real people/bots with their roles and ssh keys) and 
*partitions* (represents client groups and group abilities on 
current node) and runs Chef. Clients are filtered according to 
partitions, and linux user accounts / groups are created according to
rules defined in partitions. It is implied that client definitions are
the same for all managed nodes, and partitions should vary from node to
node - so, for example, clients may contain engineer and developer, but
developer would be allowed to visit staging servers only.

## Let me see an example

Let's define a client

```yaml
# That's client ID, it will be used for Linux user account
# if necessary
engineer:
  # Roles are represented as a tree, with leaves being just null
  # Roles are matched by filters in partitions
  roles:
    position:
      engineer: ~
    manager:
      infrastructure: ~
      application: ~
    access:
      root: ~
      sysctl: ~
  public_keys:
    id_rsa:
      content: AAAAB3NzaC1yc...
      validate: true
  private:
    id_rsa:
      content: ---BEGIN PRIVATE KEY...
      passphrase: admin
      remotes:
        corporate.infrastructure: ~
        github.com: git
        home.computer:
          Port: 22522
          User: john
      validate: true
```

Client is terribly simple. It's just an ID, a set of roles and
optional bunch of public and private keys - first are used to
login onto node, others are used to login from node. Roles are
used just as user labels, as you will see in a moment - nested
structure is implemented only not to add `something` role if
`something.thatthing` is defined.

Let's add some partitions:

```yaml
sudo-dashboard-cron:
  policy:
    # don't create linux group for that
    # that will also mean that privileges will be
    # given to users rather than to a group
    group: none
  filters:
    - cron.application.dashboard
  privileges:
    sudo:
      nopasswd: true
      command: php /var/www/dashboard/bin/console rebuild
  
superuser:
  policy:
    group: none
    # Don't even create accounts, just install the public keys
    account: none
  filters:
    - access.root + manager.infrastructure
  impersonation:
    root: ~

www-data:
  # default policy will be used - edit for group and for users
  filters:
    - bot.deploy
    - position.engineer + manager.application
    - developer.php
```

Filters are represented as a list of conditions with OR relation:
if client matches at least one condition, it matches partition.
Conditions are described as a dot-delimited role path: `bot.deploy`
matches `bot: { deploy: ~ }` and `bot: { deploy: { gently: ~ } }`,
but not just `bot: ~`.

Given those definitions, engineer client would fall under
`superuser` and `www-data` partitions (but not 
`sudo-dashboard-cron`).  So he
- Won't get any privilege
- His account will be created because `www-data` mandates so
- It will be in present in group www-data
- It also would be able to impersonate as root, which means his 
public keys will be installed on `root` account

That's quite it: client is id, roles and keys, while partition is
filters, policy, privileges and impersonation.

## Using all that knowledge

So far only the structure was described, but not how to pass it
into Chef. To use this cookbook, you will need to pass described
data into `ama_linux_user_management` resource:

```ruby
ama_linux_user_management 'default' do
  clients data_bag_items
  partitions node['ama']['user']['partitions']
end
```

And that's it. To make things even easier, some shortcuts were added:
- If partitions are not set directly, they are fetched out of
`node['ama']['user']['partitions']`
- If clients are not set directly, they are fetched out of data bag
with name stored in `node['ama']['user']['client-bag']` (`clients`
by default).
- For the laziest, this is incorporated under `default` resource.

## What is policy?

Policy defines how specific entity may be treated. There are only
three policies available:

- none: do not bother about entity, do not create it, do not edit it
- edit: freely create and edit entity, but don't delete it
- manage: same as edit, but delete entity when it is gone

The difference between edit and manage is only what happens if entity
gets deleted. Nost of the time, you'll want `manage` policy for your 
custom accounts and groups and `edit` for system users and groups - 
such as `root` and `www-data`.

## Wait a second, are you storing all that information in attributes?

*Most* of that information. All keys - private and public - are not
stored, only their digests are used to identify them.

## Shooting foots

If you ended up in this part of internet, you're

- a) Gonna mess with private and public keys. And that stuff is
terribly sensitive - of course i've put effort not to expose your
keys in state or logs, but i can't prevent you from installing
wrong key, forgetting to delete employee who has left and all other
ways to make things go south. Be double cautious.
- b) Gonna install somebody's auth key on root and grant sudo 
privileges. The warnings are quite the same, i can give you 
instrument to do this, but most of the time you should evade this
as you vampires evade light.
- c) **GONNA END WITH MANAGE POLICY ON ROOT BUT DON'T DO IT**. Root
account becomes edited the second you try to impersonate it; if, for 
any reason, all impersonation dependencies vanish, it's gonna be
garbage collected **and you'll end with a useless brick of a previously
happy node**. So just keep it edited all the way.
- d) In danger of hitting not-so-properly tested corner. I sincerely 
apologize for all the mess but i don't have currently any more time to 
develop this cookbook further.

## Important notes

- For sudo definition to be working, you have to set
`['authorization']['sudo']['include_sudoers_d']` attribute to true. 
This is required by sudo cookbook.
- All public keys set not through 
[ssh_authorized_keys cookbook][auth-keys-cookbook] will be deleted.
- Cookbook uses accumulator pattern - that means that subsequent 
resource calls would merge rather than overwrite each other. Cookbook
stores it's state in attributes, which makes it possible to remember
previously managed accounts to wipe them on new run.
- This cookbook doesn't manage `known_hosts` because it's certainly not
this cookbook's job and it would be serious security issue to import
their keys blindly and/or failing whole run because of inaccessible 
remote node unless user asked to do so.

## Contributing

Contributions are welcome! Please send your pull requests into `dev`
branch. There is whole lot of bad code and unfinished work inside,
not even mentioning proper documentation.

Also be aware that this cookbook contains a vendored gem
([ama-entity-mapper][]), which is installed using `rake vendor`

## Dev branch state

[![CircleCI branch](https://img.shields.io/circleci/project/github/ama-team/cookbook-linux-user-management/dev.svg?style=flat-square)](https://circleci.com/gh/ama-team/cookbook-linux-user-management/tree/dev)
[![Coveralls branch](https://img.shields.io/coveralls/ama-team/cookbook-linux-user-management/dev.svg?style=flat-square)](https://coveralls.io/github/ama-team/cookbook-linux-user-management?branch=dev)
[![Scrutinizer](https://img.shields.io/scrutinizer/g/ama-team/cookbook-linux-user-management/dev.svg?style=flat-square)](https://scrutinizer-ci.com/g/ama-team/cookbook-linux-user-management?branch=dev)

## Testing

Long story short: this cookbook couldn't be tested the regular way
because of scenario diversity, so small not-a-framework had to be 
developed. This cookbook has regular unit/integration suites (code 
only) with no peculiarities, but functional (ChefSpec) and
acceptance (Test Kitchen) test suites use tests described in YAML.
Those suites are located in
[`test/support/cookbooks/alum-testing/files/default/fixture/run-history`]()
and simply translate themselves into appropriate matchers. ChefSpec
tests simply read that directory out and apply stories one by one,
while Test Kitchen is configured using rake command 
`test:acceptance:setup` - this will create the required suites and
attributes.

Test reporting is done using [Allure Framework][allure] - and, in
fact, due to specifics it's not really possible to test other way.
`rake test:<type>:with-report` will run appropriate tests and
generate report in `test/report/allure`. 

## Licensing

MIT License / Created by AMA Team

  [auth-keys-cookbook]: https://supermarket.chef.io/cookbooks/ssh_authorized_keys
  [allure]: https://github.com/allure-framework/allure2
  [ama-entity-mapper]: https://rubygems.org/gems/ama-entity-mapper
