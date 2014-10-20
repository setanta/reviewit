# Review it!

Review it! is a review tool for git-based projects.

## Features

For the sake of simplicity, the work/review processes is split in two components:

- Command-line tool (requesting review for patches)
- Web-based code review dashboard

## Installing

While still in alpha development, you can try it out by cloning the repo, bundling and running the tools locally.

## Setting up your Project

1. Register your project in the web interface (just needs a name, repository URL and a list of people involved on the project)
2. Go to the directory where your project working copy is.
3. Type the command you saw in the web interface.

## Workflow for Writing Code

### Creating a Merge Request

1. Write some code!
2. Commit it to git like you are used to do
3. Feeling ready for review? Just run `review push BRANCH` command.

Your patch will be posted for review. Once accepted, it will be merged into ``BRANCH``.

e.g. `review push 3.4.0` will create a merge request with your HEAD commit targeting the 3.4.0 branch.

### Updating a Merge Request

1. Write some code!
2. Update your existing patch (git commit --amend)
3. Run `review push` command.

## Workflow for Reviewing Patches

### Accepting a Merge Request

Go to web interface and click accept and the patch should be merged.

Reviewit will try to apply and commit your patch (git am), it will tell you if it can't. And if it can't, solve the conflicts (git rebase) then send it again for review.

### List Pending Reviews for your Project

Just run `review pending`.

### Open a Review in your Browser

Just run `review open X`, where X is the MR id, you can see the MR ids when listing pending reviews. 

If X is ommited it will open the current review, if it exists.

### Open a Review in your Terminal

Don't want to wait the browser to start up? Just run `review show X`, where X is the MR id.

### Abandon a Review

You can do it on web interface or by running `review cancel`.

### Applying a patch from some MR on your working copy

Sometimes you aren't a believer and want to try the patch yourself, this is easy, just run `review apply X` where X is the MR id.

## Wish list

1. Lint support
2. CI integration

