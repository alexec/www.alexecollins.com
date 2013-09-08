---
title: "Git tips: git xpush"
tags: git,tips
---
I'd recently been suffering from builds failing because people (including myself) had been pushing changes that they hadn't run tests on, or where un-pulled changes had broken their code.

As we use Maven, there's a simple solution to this, git aliases. 

You can add the following to ~/.gitignore:

	[alias]
		xpush = !sh -c 'git pull --no-edit && mvn clean install && git push'

Now, when you do "git xpush" git pulls any new changes down, rebuilds the app (running the tests) and pushes the changes to the repo.
