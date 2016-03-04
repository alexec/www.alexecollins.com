---
title: Ansible Shell Module
date: 2016-03-04 14:00 UTC
tags: ansible
---
I've been using Ansible at work for sometime now. It has a number of great built-in modules. However, for some tasks, there is no available module. You could write your own, but it's often simpler to use the **shell module** to achieve you goal. One difference between the shell and other modules is that rather than idempotently attempting to bring the host into a specific state (e.g.  `yum: name=docker-engine` would mean mean "make sure Docker is installed"), it executes a command. This means a couple of things:

1. It can run when it does not need to run.
2. It runs, but nothing changes, but it reports as changed.
3. It runs, fails but is not marked as failed.
4. It runs, appears to have failed, but actually the failure is expected.

If you want to use the shell module, and have it reliably report changes and failures correctly, use the `when`, `changed_when`, and `failed_when` attributes.

The `changed_when` and `failed_when` attributes are used after a task has run to determine whether or not it changed or failed.

The `when` attribute can be used to determine when to run a task. Use this to prevent a long running shell task running, or to prevent a task running that does not need to be run. As a bonus task that does not run cannot be "changed" and cannot fail!

Typically you'll need to run a information gathering task before, so for example:

    - name: check to see if file X has already been created
      stat: path=fileThatWillBeCreated
      register: precondition
      changed_when: false

    - name: create file X
      shell: touch fileThatWillBeCreated
      when: not precondtion.stat.exists

Note that the information gather task is never changed.

If we know that a task will change something into a new state, or print an error if it is already in that state, we can use that:

    - name: create user
      shell: mongo create-user.js
      register: create_user
      changed_when: "'already created' not in create_user.stdout"
      failed_when: "not (create_user.stdout | search('Successfully created|already created'))"

This create user task can have already created a user, but we don't want to treat that as changed, so we ignore it. Nor do we want to treat an already created user as a failure scenario, but we can treat everything else as failure.

I hope these tips help you our working with the shell module. Let me know if you have any tips yourself in the comments below.
