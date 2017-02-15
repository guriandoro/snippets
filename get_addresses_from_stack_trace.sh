#!/bin/bash

# This script can be used to get the addresses from stack traces, so that they can be used to be resolved.
#
# A file with the following:
#
# /usr/sbin/mysqld(my_print_stacktrace+0x35)[0x88c5e5]
# /usr/sbin/mysqld(handle_fatal_signal+0x40b)[0x68685b]
# /lib64/libpthread.so.0[0x312de0eca0]
# /lib64/libc.so.6(memcpy+0x15b)[0x312ce7b4bb]
# /usr/sbin/mysqld(_my_b_write+0x8b)[0x876f9b]
# /usr/sbin/mysqld(_ZN9Log_event12write_headerEP11st_io_cachem+0xf8)[0x651d68]
# /usr/sbin/mysqld(_ZN15Query_log_event5writeEP11st_io_cache+0x24c)[0x65286c]
# /usr/sbin/mysqld(_ZN13MYSQL_BIN_LOG5writeEP9Log_event+0x18d)[0x637d3d]
# /usr/sbin/mysqld(_ZN3THD12binlog_queryENS_22enum_binlog_query_typeEPKcmbbi+0xad)[0x5917bd]
# /usr/sbin/mysqld(_Z12mysql_updateP3THDP10TABLE_LISTR4ListI4ItemES6_PS4_jP8st_ordery15enum_duplicatesb+0x993)[0x62aa03]
# /usr/sbin/mysqld(_Z21mysql_execute_commandP3THD+0x9d4)[0x5ac574]
# /usr/sbin/mysqld(_Z11mysql_parseP3THDPcjPPKc+0x4fb)[0x5b177b]
# /usr/sbin/mysqld(_Z16dispatch_command19enum_server_commandP3THDPcj+0x1056)[0x5b3616]
# /usr/sbin/mysqld(_Z10do_commandP3THD+0x126)[0x5b3e46]
# /usr/sbin/mysqld(handle_one_connection+0x325)[0x5a7375]
#
# Will generate the following output:
#
# 0x88c5e5
# 0x68685b
# 0x312de0eca0
# 0x312ce7b4bb
# 0x876f9b
# 0x651d68
# 0x65286c
# 0x637d3d
# 0x5917bd
# 0x62aa03
# 0x5ac574
# 0x5b177b
# 0x5b3616
# 0x5b3e46
# 0x5a7375
#
# Additionally, this script has the highest comment to code ratio ever :)
# ... and may not work as expected unless you input a file with the expected format (like the one seen above)

cat $1 | cut -d '[' -f 2 | cut -d ']' -f 1
