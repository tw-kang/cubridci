#!/bin/bash

export CTP_HOME=$WORKDIR/cubrid-testtools/CTP
export init_path=$CTP_HOME/shell/init_path
export CTP_SKIP_UPDATE=0

function run_test_single() {
    local TEST_CASE=$1
    local TCROOTDIRNAME=$WORKDIR/cubrid-testcases-private-ex
    local TESTDIR=$(dirname "$TEST_CASE")
    local TESTFILE=$(basename "$TEST_CASE")

    if [ ! -e "$TCROOTDIRNAME" ]; then
        echo "Check testcases path: $TCROOTDIRNAME does not exist."
        return 1
    fi

    cd "$TCROOTDIRNAME/$TESTDIR"

    if [ ! -f "$TESTFILE" ]; then
        echo "$TEST_CASE does not exist in $TCROOTDIRNAME."
        return 1
    fi

    sh "$TESTFILE" 2>&1 | tee runtime.log
    if [ $? -ne 0 ]; then
      echo "Test script $TESTFILE failed during execution."
      exit 1
    fi
    echo "Test script $TESTFILE executed successfully."
    local nameNotExt="${testfile%.*}"
    local NOKCnt=$(grep -rw NOK "${nameNotExt}.result" | wc -l)

    cd "$WORKDIR"
    [ $NOKCnt -ge 1 ] && { echo "$TEST_CASE ==> NOK"; return 1; } || { echo "$TEST_CASE ==> OK"; return 0; }
}

