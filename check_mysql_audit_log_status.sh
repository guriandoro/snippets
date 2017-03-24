#!/bin/bash

# This script can be used to check if the Audit Log plugin is enabled, and if the Audit Log file is
# being written to.
# 
# At least two variables should be checked before running:
#
# MYSQL_COMMAND -- should have a valid mysql client connection string.
# PLUGIN_NAME -- should be the plugin name used upon install. You can check this with `SHOW PLUGINS;`
#
# It uses `mail` to send an email to the root account on error, and is intended to be run as a cronjob.


MYSQL_COMMAND="mysql -u root"
TIMEOUT=5
OUTPUT_FILE="/tmp/check_mysql_audit_log_status.log"
PLUGIN_NAME="audit_log"
RECIPENT="hsan@cpg.org,jgallo@cpg.org"
HOSTNAME=`/bin/hostname -s`

# Check that notification haven't been sent
HAVE_WARNING=`tail -1 ${OUTPUT_FILE} | grep -i WARNING`
if [[ $HAVE_WARNING == *"WARNING"* ]]; then
 SEND_EMAIL=false
else
 SEND_EMAIL=true
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
if [[ "${AUDIT_LOG_PLUGIN_STATUS}" != "ACTIVE" && "${SEND_EMAIL}" == "true" ]]; then
  MAIL_BODY="WARNING. The MySQL Audit Log is not enable on ${HOSTNAME}."
  echo ${MAIL_BODY} | mail -s "[ERROR] MySQL Audit Log." ${RECIPENT}
  echo ${MAIL_BODY} >> ${OUTPUT_FILE}
  exit 1
else 
  echo "AUDIT_LOG_PLUGIN_STATUS is ACTIVE" >> ${OUTPUT_FILE}
fi

# Check if the Audit Log file exists.
if [[ ! -f ${AUDIT_LOG_FILE}  && "${SEND_EMAIL}" == "true" ]]; then
  MAIL_BODY="WARNING. It seems the MySQL Audit Log file does not exist on ${HOSTNAME}."
  echo ${MAIL_BODY} | mail -s "[WARNING] MySQL Audit Log." ${RECIPENT}
  echo ${MAIL_BODY} >> ${OUTPUT_FILE}
  exit 1
fi

DATE_AUDIT_LOG_FILE=`stat ${AUDIT_LOG_FILE} | grep Modify | awk {'print $2 " " $3'} | cut -d '.' -f 1`
DATE_AUDIT_LOG_FILE_UNIX_TIMESTAMP=`date --date"=${DATE_AUDIT_LOG_FILE}" +%s`

# Check if the Audit Log file has been written to since we started.
if [[ "${DATE_AUDIT_LOG_FILE_UNIX_TIMESTAMP}" -lt "${DATE_UNIX_TIMESTAMP}" && "${SEND_EMAIL}" == "true" ]]; then
  MAIL_BODY="WARNING. It seems the MySQL Audit Log file is not being written to on ${HOSTNAME}."
  echo ${MAIL_BODY} | mail -s "[WARNING] MySQL Audit Log." ${RECIPENT}
  echo ${MAIL_BODY} >> ${OUTPUT_FILE}
  exit 1
else
  echo "The Audit Log file was last modified on " $DATE_AUDIT_LOG_FILE >> ${OUTPUT_FILE}
fi

exit 0