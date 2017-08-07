

This cookbook operates using following entities:

- Client is an entity describing external client (real person or bot)
whose access to nodes is managed by Chef. Every client has unique id,
set of roles and set of public keys for authentication. Roles are 
represented as a tree: "developer" role may have child roles "php" and
"senior".
- Key represents public/private key pair (specifying private key is 
purely optional). It may be used as a credential for node access 
(authorized key), installed on node for outgoing connections of 
specific user or both.
- Partition is a collection of clients that are managed identically. 
Partition defines which clients it manages using role filters, and
specifies what should be done with selected clients: they may be given
option to login under specific account (say, root), have privileges
(sudo access), have their own personal accounts and be included in 
specific Linux group.
- Account is a standard Linux user account on target node. Account is 
created for corresponding client if it is in at least one partition 
with 'create accounts' policy.

It is implied that all clients come from some kind of CMDB - that may 
be LDAP, data bag or something else - then they are passed through 
partitions of a specific node which determine, who and how will be 
managed on that particular node.

Cookbook distinguishes two policies of resource management - 
'update only' and 'full management'. Former one (represented as 
`:edit`) means that cookbook may update resource or create it if it is
missing, but will never delete it. Latter one (`:manage`) is supposed
to delete resource if it isn't used any more and garbage collection is
turned on.
