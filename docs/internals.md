---
title: Internals
---

This cookbook has quite messy architecture, but, however, it works. It
looks like this from above:

- `ama_linux_user_management` resource is called throughout compile 
phase. It passes everything it's been called with to 
`ama_linux_user_management_accumulator` with specified context, so all
data for one context will eventually merge into one definition.
Accumulator subscribes onto current `ama_linux_user_management`, so
it would be called at the end of the run.
- `ama_linux_user_management_accumulator` is eventually applied.
It uses `AMA::Chef::User::StateBuilder` to build target state, loads
current state using `AMA::Chef::User::State::Persister`, and then
passes those two versions to `AMA::Chef::User::Planner`. State is
a simple structure (`AMA::Chef::User::Model::State`) and consists
of well-defined models.
- Planner emits list of actions required to reach target state. Each
action is a standalone object that has an `.apply(resource_factory)` 
method. `resurce_factory` is just an object that allows resource 
definition using classic resource DSL, so `.apply()` may define new 
resources required to reach target state.
- Actions are applied, emitting new resources
- Resources are ran, system converges to target state
- `ama_linux_user_management_accumulator` calls the persister to save
new system state.

So, basically, it's kinda Chef-in-Chef (and this apparently sucks).
However, i failed to implement anything working yet understandable
that would support persistence and would automatically detect deleted
users/groups.

## Privileges

The other PITA is privilege handling. I'm not sure there are other 
privileges rather than sudo in Linux, but left option to specify
privileges of different types - just in case. So, user have to specify
different privileges (which will result in different resources) in a 
same way - and that requires some kind of plug-in system. This was 
implemented in `AMA::Chef::User::Handler::Privilege` class that 
acts both as a base for privilege handlers and a handler registry. 
Every handler has to register itself in registry before the run, so 
it could be found during the run.
You can see an example in `libraries/handler/**/*.rb`.

## Models

All the work is done managing model objectss rather than hashes of 
attributes. All models are located in `libraries/model` directory. 
Every model supports `==`, `normalize`, `self.denormalize` and 
`self.denormalize_hash` methods.

## Isn't it too Java for Ruby?

Quite sad, but yes ( 

I just can't code in standard Ruby way.
