#!/bin/bash -le

export CTP_HOME=$WORKDIR/cubrid-testtools/CTP
export init_path=$CTP_HOME/shell/init_path
export CTP_SKIP_UPDATE=0

TEST_CASE=$1
TCROOTDIRNAME=$WORKDIR/cubrid-testcases-private-ex
TESTDIR=$(dirname "$TEST_CASE")
TESTFILE=$(basename "$TEST_CASE")

#run_build
if [ -f ./build.sh ]; then
  CUBRID_SRCDIR=.
elif [ -f cubrid/build.sh ]; then
  CUBRID_SRCDIR=$WORKDIR/cubrid
else
  echo "Cannot find CUBRID source directory!"
  exit 1
fi

#(cd $CUBRID_SRCDIR \
#  && ./build.sh -p $CUBRID -g ninja clean build) | tee build.log 
#if grep -q "Building failed" build.log; then
#    tail -500 build.log
#    exit 1
#fi


#run_test_single
if [ ! -d "$TCROOTDIRNAME/$TESTDIR" ]; then
    echo "Check testcases path: $TCROOTDIRNAME does not exist."
    exit 1
fi
if [ ! -f "$TCROOTDIRNAME/$TESTDIR/$TESTFILE" ]; then
    echo "$TEST_CASE does not exist in $TCROOTDIRNAME."
    exit 1
fi

cd "$TCROOTDIRNAME/$TESTDIR"
sh $TESTFILE &
wait $!
if [ $? -ne 0 ]; then
    echo "Test script $TESTFILE failed during execution."
    exit 1
fi
nameNotExt="${TESTFILE%.*}"
NOKCnt=$(grep -rw NOK "${nameNotExt}.result" | wc -l)

[ $NOKCnt -ge 1 ] && { echo "$TEST_CASE ==> NOK"; exit 1; } || { echo "$TEST_CASE ==> OK"; exit 0; }

