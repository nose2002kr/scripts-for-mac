#!/bin/bash

STASH_NAME=`git stash list | grep Testing-Env |  awk -F: '{ print $1 }'`
if [ -z "$STASH_NAME" ]; then
    echo "No stash found with name 'Testing-Env'."
    exit 1
fi

GITIGNORE_FILE=~/.local/.gitignore-`basename $(git rev-parse --show-toplevel)`

DIFF_FILES=`git stash show --name-status refs/$STASH_NAME`
DIFF_NEW_FILE=`echo "$DIFF_FILES" | grep -E '^A' | awk '{ print $2 }'`
DIFF_MODIFIED_FILE=`echo "$DIFF_FILES" | grep -E '^M' | awk '{ print $2 }'`

git stash apply refs/$STASH_NAME $1>/dev/null
git update-index --skip-worktree $DIFF_MODIFIED_FILE

echo $DIFF_NEW_FILE > $GITIGNORE_FILE
git config --local core.excludesfile $GITIGNORE_FILE
git reset -- $DIFF_NEW_FILE $DIFF_MODIFIED_FILE $1>/dev/null
