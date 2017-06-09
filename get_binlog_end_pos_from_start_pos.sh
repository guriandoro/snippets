#!/bin/bash

# 1st argument is the full or relative path to the binary log in question
# 2nd argument is the start postion for which we want to know the end_log_pos

# Return value is the end_log_pos according to the mysqlbinlog output, so we
# can use it with a subsequent mysqlbinlog command with --stop-position to get
# the full event (and only that one).

BINLOG=$1
START_POS=$2

mysqlbinlog --verbose --base64-output=decode-rows --start-position=$START_POS $BINLOG | \
  grep end_log_pos | \
  head -n 1 | \
  tr '\ ' '\n' | \
  grep -A 1 end_log_pos | \
  tail -n 1
