#!/bin/sh
# 2011-10-20, Created by Hagen Fuchs <hfuchs@pks.mpg.de>
#
# Purpose: Understand git's merging behaviour.

dir=/tmp/gitnarios.$$

# Bit of sanity
trap "rm -rf $dir" EXIT INT

comment () {
    echo -e "\E[31m $* \E[37m"
}

scenario_one () {
    comment "------- Set up central repository."
    mkdir -p $dir/origin
    cd $dir/origin
    git init --bare

    echo "------- Clone into two repos, alice and bob."
    cd ..
    git clone origin alice
    git clone origin bob

    echo "------- Alice: Create README and push to origin."
    cd alice
    echo "Hello" > README
    git add README
    git commit -m "alice: Add README."
    git push origin master

    echo "------- Bob: Pull, add new file and push to origin."
    cd ../bob
    git pull
    echo "bob" > bob
    git add bob
    git commit -m "bob: Add bob."
    git push

    echo "------- Alice: DON'T pull, add new file and push to origin."
    cd ../alice
    echo "alice" > alice
    git add alice
    git commit -m "alice: Add alice."
    git push
    cat << ENDOFMSG
-----------------------------------------------------------------
Scenario 1 - Non-fast-forward updates were rejected.

Consider this graph:

    [Alice], A1 ----------- A2
     /        \ push         \ push
[0rigin] ----- A1 ------ B1 -!!!
     \          \ pull  / push
     [Bob] ----- A1 -- B1

The clash happens because A2 is child of A1, not B1!  Thus Alice may
either 'push --force' A2, thereby expunging B1(!), or merge B1 into
alice/master and push the merge patch.
ENDOFMSG
}

scenario_two () {
    echo "------- Set up two independent repositories."
    mkdir -p $dir/a && cd $dir/a && git init
    echo "a" > README
    git add README
    git commit -m "README A"

    mkdir -p $dir/b && cd $dir/b && git init
    echo "b" > README
    git add README
    git commit -m "README B"

    echo "------- Add repo A as remote of B and fetch."
    git remote add a $dir/a
    git fetch a

    echo "------- Current config."
    cat .git/config
    git branch -a

    echo "------- Merge."
    git merge a/master

    cat << ENDOFMSG
-----------------------------------------------------------------
Scenario 2 - Merge-Replace a file (aka You Don't Lose History).

I was plagued by an interesting question today: What happens if two
repositories, A & B, create a file with the same name (different
content) and /afterwards/ Bob makes Alice's repo one of his remotes.
The files have no common commit in their history, so will git silently
replace the file's history?  No.  It's just a sane merge.
ENDOFMSG
}

scenario_one
#scenario_two

