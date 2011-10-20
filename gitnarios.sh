#!/bin/sh
# 2011-10-20, Created by Hagen Fuchs <hfuchs@pks.mpg.de>
#
# Purpose: Understand git's merging behaviour.

dir=/tmp/gitnarios

# Bit of sanity
trap "rm -rf $dir" EXIT INT

scenario_one () {
    mkdir -p $dir/origin
    cd $dir/origin
    git init --bare

    cd ..
    git clone origin alice
    git clone origin bob

    cd alice
    echo "Hello" > README
    git add README
    git commit -m "alice: Add README."
    git push origin master

    cd ../bob
    git pull
    echo "bob" > bob
    git add bob
    git commit -m "bob: Add bob."
    git push

    cd ../alice
    echo "alice" > alice
    git add alice
    git commit -m "alice: Add alice."
    git push
    cat << ENDOFMSG
-----------------------------------------------------------------
Scenario 2 - Non-fast-forward updates were rejected.

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

scenario_one
