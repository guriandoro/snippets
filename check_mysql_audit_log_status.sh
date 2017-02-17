#!/bin/bash

MYSQL_COMMAND="mysql -uroot"
TIMEOUT=1
OUTPUT_FILE="/tmp/check_mysql_audit_log_status.log"
PLUGIN_NAME="audit_log"

# Date in unix timestamp format, so we can check if the audit log file was modified after querying mysql.
DATE_UNIX_TIMESTAMP=`date +%s`

# The audit-log-file mysql variable needs to include full path, if not, one should modify the code to
# prepend the datadir path.
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
if [ "${AUDIT_LOG_PLUGIN_STATUS}" != "ACTIVE" ]; then
  MAIL_BODY="ERROR! The MySQL Audit Log is not enabled."
  echo ${MAIL_BODY} | mail -s "[ERROR] MySQL Audit Log." root@localhost
  echo ${MAIL_BODY} >> ${OUTPUT_FILE}
  exit 1
else 
  echo "AUDIT_LOG_PLUGIN_STATUS is ACTIVE" >> ${OUTPUT_FILE}
fi

# Check if the Audit Log file exists.
if [ ! -f ${AUDIT_LOG_FILE} ]; then
  MAIL_BODY="WARNING. It seems the MySQL Audit Log file does not exist."
  echo ${MAIL_BODY} | mail -s "[WARNING] MySQL Audit Log." root@localhost
  echo ${MAIL_BODY} >> ${OUTPUT_FILE}
  exit 1
fi

DATE_AUDIT_LOG_FILE=`stat ${AUDIT_LOG_FILE} | grep Modify | awk {'print $2 " " $3'} | cut -d '.' -f 1`
DATE_AUDIT_LOG_FILE_UNIX_TIMESTAMP=`date --date"=${DATE_AUDIT_LOG_FILE}" +%s`

# Check if the Audit Log file has been written to since we started.
if [ "${DATE_AUDIT_LOG_FILE_UNIX_TIMESTAMP}" -lt "${DATE_UNIX_TIMESTAMP}" ]; then
  MAIL_BODY="WARNING. It seems the MySQL Audit Log file is not being written to."
  echo ${MAIL_BODY} | mail -s "[WARNING] MySQL Audit Log." root@localhost
  echo ${MAIL_BODY} >> ${OUTPUT_FILE}
  exit 1
else
  echo "The Audit Log file was last modified on " $DATE_AUDIT_LOG_FILE >> ${OUTPUT_FILE}
fi

exit 0
