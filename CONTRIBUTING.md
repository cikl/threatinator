Contributing to Threatinator
============================

You're encouraged to submit [pull requests](https://github.com/cikl/threatinator/pulls), [propose features and discuss issues](https://github.com/cikl/threatinator/issues).

#### Fork the Project

Fork the [project on Github](https://github.com/cikl/threatinator) and check out your copy.

```
git clone https://github.com/contributor/threatinator.git
cd threatinator
git remote add upstream https://github.com/cikl/threatinator.git
```

#### Create a Topic Branch

All active development is based off of our 'develop' branch. So, make sure your references are up to date, and create your topic branch off of upstream/develop.

```
git fetch upstream
git checkout -b my-feature-branch upstream/develop
```

#### Write Tests

If the area of code that you're working on supports unit tests, add tests. 
Also, be sure to run all tests to make sure you didn't break anything.

#### Write Code

Implement your feature or bug fix.

#### Write Documentation

Document any external behavior in the [README](README.md).

#### Update Changelog

Add a line to [CHANGELOG](CHANGELOG.md) under *Next Release*. Make it look like every other line, including your name and link to your Github account.

#### Commit Changes

Make sure git knows your name and email address:

```
git config --global user.name "Your Name"
git config --global user.email "contributor@example.com"
```

Make commits of logical units. This might mean making multiple commits if you're changing distinct bits of functionality. 
```
git add ...
git commit
```

It's very important that you write a good commit log! It should describe what changed and why. If you're fixing an issue that is already tracked within Github, mention it!

````
    Make a commit title that is brief and to the point

    - Describe the change you made, and why you made it.
    - Context is vital to a good commit message. Try to get future developers
      up to speed with what your change does so that they don't bother you
      offline. 
    - Mention any relevant Threatinator issues by mentioning the number like this #55 
    - Github will automatically close any issues when your pull request is
      accepted if you do something like this: closes #123

````

#### Rebase

It's easy to for your feature branch to fall behind any changes that have been made in the main repository. This is to be expected on actively developed projects.
In order to make sure that your changes will still work when merged into the main repo, it's a good idea to rebase your feature branch. This basically peels the commits off of your feature branch, pulls in any updates that have been made to upstream/develop, and then re-applies your commits. If all goes well, your commits will apply cleanly. If, however, someone else has made changes to the same code as you, git will report the conflicts and give you a chance to fix anything. 

Basically, this will help ensure that your code will merge properly with any changes that may have been made in the main repository. If there are any conflicts, it will be easier to deal with those now, rather than finding out that your pull request can't merge.

```
git fetch upstream
git rebase upstream/develop
```

#### Push

```
git push origin my-feature-branch
```

#### Make a Pull Request

Go to https://github.com/contributor/threatinator and select your feature branch. Click the 'Pull Request' button and fill out the form. Pull requests are usually reviewed within a few days.

#### Update CHANGELOG Again

Update the [CHANGELOG](CHANGELOG.md) with the pull request number. A typical entry looks as follows.

```
* [#123](https://github.com/cikl/threatinator/pull/123): Reticulated splines - [@contributor](https://github.com/contributor).
```

Amend your previous commit and force push the changes.

```
git commit --amend
git push origin my-feature-branch -f
```

#### Check on Your Pull Request

Go back to your pull request after a few minutes and see whether it passed muster with Travis-CI. Everything should look green, otherwise fix issues and amend your commit as described above.

#### Be Patient

It's likely that your change will not be merged and that the nitpicky maintainers will ask you to do more, or fix seemingly benign problems. Hang on there!

#### Thank You

Please do know that we really appreciate and value your time and work. We love you, really.
