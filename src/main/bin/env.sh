MAIN_CLASS=testweb.demo.DemoApplication
SERVER_PORT=8000
JAVA_OPTS=" -Xms1g -Xmx1g -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8"

BIN=`echo "$( cd -P "$( dirname "${0}" )" && pwd )" `
SHELL_LOG="${BIN}/console.out"
SERVICE_LOG_PATH=${BIN}/../logs
SERVICE_CONF_PATH=${BIN}/../conf
#PID_FILE_PATH=${BIN}/../pid
LIB_PATH=${BIN}/../lib

CLASSPATH=${LIB_PATH}"/*:"${SERVICE_CONF_PATH}":."
JAVA_OPTS=${JAVA_OPTS}" -XX:HeapDumpPath="${SERVICE_LOG_PATH}" -Dlog.path="${SERVICE_LOG_PATH}
JAVA_OPTS=${JAVA_OPTS}" -Dserver.port="${SERVER_PORT}" "
#JAVA_OPTS=${JAVA_OPTS}" -Dpid.file="${PID_FILE_PATH}
#JAVA_OPTS=${JAVA_OPTS}" -Dlogging.config="${SERVICE_CONF_PATH}"/logback.xml"
JAVA_OPTS=${JAVA_OPTS}" -classpath "${CLASSPATH}

EXE_JAVA="java "${JAVA_OPTS}" "${MAIN_CLASS}
JPS="jps"

#mkdir
mkdir -p $SERVICE_LOG_PATH

# check if the process still in jvm
function check_status(){
    local p=""
    if [ -f ${PID_FILE_PATH} ]; then
        local pid_in_file=`cat ${PID_FILE_PATH} 2>/dev/null`
        if [ "x"${pid_in_file} !=  "x" ]; then
          p=`${JPS} -q | grep ${pid_in_file} | awk '{print $1}'`
        fi
    else
        p=`${JPS} -l | grep "$1" | awk '{print $1}'`
    fi

    #
    if [ -n "$p" ]; then
        # echo "$1  is still running with pid $p"
        return 0
    else
        # echo "$1  does not appear in the java process table"
        return 1
    fi
}

function wait_for_startstop(){
    cmd=$1   # start/ stop
    sleep_time=$2

    local now_s=`date '+%s'`
    local stop_s=$((${now_s} + ${sleep_time}))
    echo $stop_s
    while [ ${now_s} -le ${stop_s} ];do
        check_status ${MAIN_CLASS}
        service_status=$?

        if [ "x"${cmd} = "xstart" ]; then
            if [ ${service_status} -eq 0 ]; then
                # echo "$1  is still running with pid $p"
                return 0
            fi
        else
            if [ ${service_status} -eq 1 ]; then
                # echo "$1  stopped success "
                return 0
            fi
        fi

        sleep 1
        now_s=`date '+%s'`
    done
    exit 1
}


function usage(){
    echo " usage is [start|stop|status]"
}

function LOG(){
  currentTime=`date "+%Y-%m-%d %H:%M:%S.%3N"`
  echo -e "$currentTime [${1}] ($$) $2" | tee -a ${SHELL_LOG}
}