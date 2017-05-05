#!/bin/bash

# This script can be used to check if the Audit Log plugin is enabled, and if the Audit Log file is
# being written to.
#
# At least two variables should be checked before running:
#
# MYSQL_COMMAND -- should have a valid mysql client connection string.
# PLUGIN_NAME -- should be the plugin name used upon install. You can check this with `SHOW PLUGINS;`
#
# Created by https://github.com/guriandoro/snippets, modify by Henry San

MYSQL_COMMAND="/usr/bin/mysql --defaults-extra-file=/root/.my.cnf"
TIMEOUT=5
OUTPUT_FILE="/tmp/check_mysql_audit_log_status.log"
PLUGIN_NAME="audit_log"
HOSTNAME=`/bin/hostname -s`

# function to post to slack
slack() {
  /usr/bin/curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$1\"}" https://hooks.slack.com/services/XXXXXXXXXXXXXXXXXXXXXX
}

# Check that notification haven't already been sent
HAVE_WARNING=`tail -1 ${OUTPUT_FILE} | grep -i WARNING`
if [[ $HAVE_WARNING == *"WARNING"* ]]; then
 SEND_SLACK=false
else
 SEND_SLACK=true
fi

# Date in unix timestamp format, so we can check if the audit log file was modified after querying mysql.
DATE_UNIX_TIMESTAMP=`date +%s`

# The audit-log-file mysql variable needs to include full path, if not, one should modify the code to
# prepend the datadir path
AUDIT_LOG_FILE=`${MYSQL_COMMAND} -Bse "SELECT @@global.audit_log_file" 2>/dev/null`

# This command should return "ACTIVE" if the audit log plugin is enabled.
AUDIT_LOG_PLUGIN_STATUS=`${MYSQL_COMMAND} -Bse "SHOW PLUGINS" 2>/dev/null | grep ${PLUGIN_NAME} | awk {'print $2'}`

# This is simply used to give some time for the logs to be written to, to avoid false positives when
# comparing timestamps. Since we are querying mysql, at least our SELECT issued above should have been
# logged. If this check is not needed or wanted, set TIMEOUT=0.
sleep ${TIMEOUT}


# Write date to output log file.
date >> ${OUTPUT_FILE}

# Check if the Audit Log plugin is enabled.
if [[ "${AUDIT_LOG_PLUGIN_STATUS}" != "ACTIVE" && "${SEND_SLACK}" == "true" ]]; then
  BODY="WARNING. The MySQL Audit Log is not enable on ${HOSTNAME}."
  slack "${BODY}"
  echo ${BODY} >> ${OUTPUT_FILE}
  exit 1
else
  echo "AUDIT_LOG_PLUGIN_STATUS is ACTIVE" >> ${OUTPUT_FILE}
fi

# Check if the Audit Log file exists.
if [[ ! -f ${AUDIT_LOG_FILE}  && "${SEND_SLACK}" == "true" ]]; then
  BODY="WARNING. It seems the MySQL Audit Log file does not exist on ${HOSTNAME}."
  slack "${BODY}"
  echo ${BODY} >> ${OUTPUT_FILE}
  exit 1
fi

DATE_AUDIT_LOG_FILE=`stat ${AUDIT_LOG_FILE} | grep Modify | awk {'print $2 " " $3'} | cut -d '.' -f 1`
DATE_AUDIT_LOG_FILE_UNIX_TIMESTAMP=`date --date"=${DATE_AUDIT_LOG_FILE}" +%s`

# Check if the Audit Log file has been written to since we started.
if [[ "${DATE_AUDIT_LOG_FILE_UNIX_TIMESTAMP}" -lt "${DATE_UNIX_TIMESTAMP}" && "${SEND_SLACK}" == "true" ]]; then
  BODY="WARNING. It seems the MySQL Audit Log file is not being written to on ${HOSTNAME}. will try to auto resolve it."
  slack "${BODY}"
  echo ${BODY} >> ${OUTPUT_FILE}
  mv -f "${AUDIT_LOG_FILE}" "${AUDIT_LOG_FILE}.${DATE_UNIX_TIMESTAMP}"
  ${MYSQL_COMMAND} -Bse "set global audit_log_rotate_on_size = 0; set global audit_log_flush = ON; set global audit_log_rotate_on_size = 512000000;"
  exit 1
else
  echo "The Audit Log file was last modified on " $DATE_AUDIT_LOG_FILE >> ${OUTPUT_FILE}
fi

exit 0
