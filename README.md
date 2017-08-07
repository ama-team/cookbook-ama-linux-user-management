# --- Work In Progress ---

# Cookbook ama-linux-user-management

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

Imagine following client specification

```yml
# That's client ID, it will be used for Linux user account
# if necessary
engineer:
  keys:
    # Keys have their own IDs, they will be used in 
    # authorized_keys and/or file names 
    engineer@work:
      type: ssh-rsa
      # If you want just to let user in by key, this is the only 
      # required field
      public: AAAAB3NzaC1yc...
      private: ...
      local:
        enabled: true
        options: {}
      remote:
        enabled: true
        hosts:
          bitbucket.org:
            port: 22
            user: git
          github.com: git
          ingress.company.com: ~
  # Unless traditional setups, roles take this weird tree-like approach
  roles:
    ops: ~
    access-level:
      k8s:
        full: ~
developer:
  keys: 
    developer@work: AAAAB3NzaC1yc...
  roles:
    developer:
      php: ~
deploy-bot:
  keys: ...
  roles:
    deploy:
      php: ~
      java: ~
cto:
  keys: ...
  roles:
    cto: ~
```

And following partitions attached to current node:

```
www-data:
  # Filters define which clients will be matched by partition
  # Dots represent tree level separation
  filters:
    - developer.php
    - deploy.php
    - ops
sudo:
  filters:
    - ops
  privileges:
    # Sadly, this is the only privilege available by today
    sudo: true
  policy:
    # By default, cookbook is allowed only to create and edit 
    # groups/accounts (:edit policy), :manage allows full access
    # including garbage collection 
    group: manage
root:
  filters:
    - ops
    - cto
  # Allow matching clients to login as those accounts
  impersonation:
    root: ~
  policy:
    # This is 'install auth keys only' partition, do not create 
    # linux user accounts at all
    account: none
```

When those definitions are passed to `ama_linux_user_management` 
resource:

```ruby
ama_linux_user_management 'default' do
  users data_bag_items
  partitions node['ama']['user']['partitions']
  collect_garbage false
end
```
 
And Chef is ran, following actions will be taken:

- `engineer`, `developer` and `deploy-bot` accounts will be created.
This will happen because default `account` partition policy is equal to 
`:edit`, and they all are mentioned in `www-data`. All mentioned 
accounts will be appended to Linux group `www-data` (because of default
`:edit` policy).
- `engineer` will be added to `sudo` group. The `sudo` group will be 
fully managed by Chef (`:manage` policy), which means that only users
specified during Chef run will be included in group. The group is 
specified as privileged, which means it's members will be allowed to 
use sudo.
- `engineer` and `cto` keys will also be added to authorized_keys for
`root` account. The `root` partition specifies default policy on Linux 
group (that's `:none`), so it won't be managed at all, `users` policy
is specified as `:none`, so `cto` account won't be created.

You may specify clients and partitions directly or leave attributes 
intact - in that case resource will attempt to use `clients` data bag 
and `['ama']['user']['partitions']` node attribute. Resource expects to
receive data in format specified above.

`ama-linux-user-management::default` recipe contains empty resource 
call for the laziest.

## Garbage collection

Most of the times, when user or partition is gone, corresponding user,
sudoer definition or group should be deleted as well. Cookbook allows
such behavior (deletion all groups and users with `:manage` policy as 
soon as they are not present during new Chef run) if 
`collect_garbage` resource property is set to true. This behavior 
may have dramatic consequences if you are directly managing 
system-critical users (root, in first place), so by default this 
property is turned off. Be sure not to shoot your foot off.

## Important notes

- For sudo definition to be working, you have to set
`['authorization']['sudo']['include_sudoers_d']` attribute to true. 
This is required by sudo cookbook.
- All public keys set not through 
[ssh_authorized_keys cookbook][auth-keys-cookbook] will be deleted.
- This cookbook attempts to do it's best to drop access for revoked
clients, however, if client A was the only one to impersonate account
B, client A's keys may be left intact even upon garbage collection.
However, if there's at least one key for user set during Chef run, all
other keys will be dropped.
- Cookbook uses accumulator pattern - that means that subsequent 
resource calls would merge rather than overwrite each other. Cookbook
stores it's state in attributes, which makes it possible to remember
previously managed accounts to wipe them on new run.
- This cookbook doesn't manage `known_hosts` because it's certainly not
this cookbook's job and it would be serious security issue to import
their keys blindly and/or failing whole run because of inaccessible 
remote node unless user asked to do so.

# Licensing

MIT License / Created by AMA Team

  [auth-keys-cookbook]: https://supermarket.chef.io/cookbooks/ssh_authorized_keys