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

rm $GITIGNORE_FILE 2>/dev/null
git config --local --unset-all core.excludesfile

git update-index --no-skip-worktree $DIFF_MODIFIED_FILE

git add $DIFF_NEW_FILE 2>/dev/null

for FILE in $DIFF_MODIFIED_FILE $DIFF_NEW_FILE; do
    if [ -z "$FILE" ]; then
        continue
    elif [ ! -f "$FILE" ]; then
        continue
    elif (! git status --porcelain $FILE | grep -q '^A') && git diff --quiet --exit-code "$FILE"; then
        continue
    fi
    
    git diff --quiet --exit-code refs/$STASH_NAME $FILE
    if [ $? -ne 0 ]; then
        echo "Changes detected in $FILE. do you want to discard these changes? ([y]/n)"
        read -r answer
        if [[ "$answer" == "n" || "$answer" == "N" ]];
        then
            DIFF_MODIFIED_FILE=`echo "$DIFF_MODIFIED_FILE" | sed "s|$FILE||g"`
            DIFF_NEW_FILE=`echo "$DIFF_NEW_FILE" | sed "s|$FILE||g"`
            echo "Changes in $FILE will not be discarded."
        fi
    fi
done

rm $DIFF_NEW_FILE 2>/dev/null

git reset -- $DIFF_NEW_FILE 1>/dev/null
git checkout $DIFF_MODIFIED_FILE
