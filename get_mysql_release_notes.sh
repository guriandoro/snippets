#!/bin/bash

# You can use this script to get MySQL release notes. You can then use grep(1) to search for
# strings you want, or even bug numbers, to see if any bugs were fixed in any particular patch.
#
# The script should be called in the following way (note the only checks done are for empty
# parameters, there are no checks of any other kinds.
# For release notes from 5.6.28 to 5.6.34, use:
#
# sh /path/to/get_mysql_release_notes.sh 5 6 28 34
#
# The script will create a `./release_notes_5.6` directory if none exists already (note that
# it uses current working directory, so where you call the script from matters for it).
#
# As of today, the following MAJOR.MINOR versions are working:
#
# 5.5
# 5.6
# 5.7
# 8.0
#
# As a last comment, note that if a non-existent patch number is used, wget will not fail, 
# but you will have the 'Page not found' html downloaded :)

if [ -z "$4" ]; then
  echo >&2 'Error: Not enough parameters.'
  echo >&2 'Usage: get_mysql_release_notes.sh <major> <minor> <min_patch> <max_patch>'
  exit 1
fi

MAJOR="$1"
MINOR="$2"
PATCH_MIN="$3"
PATCH_MAX="$4"

RELEASE_NOTES_DIR="release_notes_${MAJOR}.${MINOR}/"

if [ ! -d "$RELEASE_NOTES_DIR" ]; then
  mkdir ${RELEASE_NOTES_DIR};
fi

cd ${RELEASE_NOTES_DIR};

for PATCH in `seq $PATCH_MIN $PATCH_MAX`; do
  wget http://dev.mysql.com/doc/relnotes/mysql/${MAJOR}.${MINOR}/en/news-${MAJOR}-${MINOR}-${PATCH}.html;
done
