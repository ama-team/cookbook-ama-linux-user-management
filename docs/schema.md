---
title: Schema
---

## Public Key

```yml
<id:string>:
  id: <string, optional>
  type: <string, optional, default: ssh-rsa>
  content: <string>
  validate: <bool, optional>
```

Example:

```yml
workstation:
  type: ssh-rsa
  content: AAAAB3NzaC1yc2EAAAADAQABAAAAYQCyyJ+QSCySnhILTrfx3hB5qhssY/NVuqUuovZ3yIG362O0AL7aICUyzav/ZAhtC5/IKXq748EG2gOZ+Cfgclv3fl+F9HvaRUwwoDmqofde6lbg3xxojMcOjSvE8EXSWfU=
  validate: false
```

## Private Key

```yml
<id:string>:
  id: <string, optional>
  type: <string, optional, default: ssh-rsa>
  content: <string, optional>
  public_key: <string, optional>
  passphrase: <string, optional>
  remotes:
    <host:string>: <hash{string, string}|string|nil, optional>
  validate: <bool, optional>
  install_public_key: <bool, optional>
```

Example:

```yml
id_rsa:
  content: |
    -----BEGIN RSA PRIVATE KEY-----
    MIIBygIBAAJhALLIn5BILJKeEgtOt/HeEHmqGyxj81W6pS6i9nfIgbfrY7QAvtog
    JTLNq/9kCG0Ln8gpervjwQbaA5n4J+ByW/d+X4X0e9pFTDCgOaqh917qVuDfHGiM
    xw6NK8TwRdJZ9QIDAQABAmB0NveKCXB36iqekQ//ODOLcqjxRRODUa1YUHRYTs0L
    qgaIlsd48NZdXNaGUBcuExQ3DVpP+10s900mKhWKZhaXifBg1xXMognfwyM3+eGq
    XA7/CxG9z97d+u+JEjTCN+0CMQDai2QAvbPUkHe3vm3HiiDsvLDxi9qHSo+LzFBY
    2IW4uq5yZyqnnWIWHPikeoJQHhMCMQDRbLuOhRfG2FZmCXZh1m5pTADaijS9HBjh
    igWUjhe+TANw484+50D52HsqZp8ViNcCME9byoaSXFjV1QM9/TM2L1qH8mDj/gie
    xJ1pJcv9ZCF+eJZGbDDNb67D+m4Ppn5dTQIwaDs/1h0zykneJobLHsLEzS+AtURY
    H08eqxIw2NEnzBS1Gbin6/LZCgDOvDm7L9KdAjEAyCSh1MXhHUSbUMZkLDrx0ANO
    Z+OruLcAbJ4tocwVwuOAEQpl8mj6dHDc8jWeHiMc
    -----END RSA PRIVATE KEY-----
  remotes:
    engineer.home: ~
    bitbucket.org: git
    internal.enterprise:
      User: engy
      Port: 22
      ForwardAgent: 'yes'
  validate: true
  install_public_key: false
```

Private keys are installed with [`ama-ssh-private-keys`][ama-ssh-private-keys]
cookbook, validation will require ssh-keygen to be installed, public
key installation will require ssh-keygen or type and public key to be set.

## Client

```yml
<id:string>
  id: <string, optional>
  roles: <hash>
  keys: <hash{string, Key}>
```

Example:

```yml
engineer:
  roles:
    ops: ~
    access:
      monitoring: ~
      database: ~
      kubernetes:
        master: ~
  keys: {}
```

## Partition

```yml
<id:string>:
  id: <string, optional>
  filters: <string[]>
  privileges:
    sudo:
      enabled: <bool, default false>
      options: <hash{string, string}, optional>
  impersonation: <hash{string, nil}, optional>
  policy:
    account: <string, [none, edit, manage]>
    group: <string, [none, edit, manage]>
```

Example:

```yml
sudo:
  filters:
    - ops
    - cto
    - developer.senior
    - audit + access-level.gamma
  privileges:
    sudo:
      nopasswd: true
  impersonation:
    root: ~
  policy:
    account: manage
    group: manage
```

Partition consists of filters that match clients, privileges that would
be given to accounts, list of accounts clients would be able to login 
as (impersonation) and user / group management policy.

Filters are represented by dot-delimited role paths that clients would
be matched against. Filter `developer.senior` will match clients that
have `developer` role with child `senior`:

```yml
php-developer:
  roles:
    developer:
      senior: ~
```

Client has to match at least one filter to be included in partition, so
filter collection resembles or-relation. If you need and-relation, you
may use plus sign:

```yml
filters:
  - audit + access-level.gamma
```

Such filter will match only clients that have both `audit` and 
`access-level.gamma` roles.

Privileges are specified as a hash. At the moment of writing only 
`sudo` privilege has been added.

Impersonation stands for hash of accounts that would be accessible
using partition client keys. Currently there are no options available,
hash structure is reserved for future use.

Policy defines how user accounts and group will be managed. `:none`
stands for 'do not create', `:edit` means 'edit and create if needed, 
but do not delete', while `:manage` implies 'create, edit and delete if
needed'.
