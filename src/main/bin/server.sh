BIN=`echo "$( cd -P "$( dirname "${0}" )" && pwd )" `
source  ${BIN}/env.sh


start(){
    check_status ${MAIN_CLASS}
    if [ $? -eq 0 ]; then
        LOG INFO "service has been started in process"
        exit 0
    fi
    LOG INFO ${EXE_JAVA}
    nohup ${EXE_JAVA} >${SHELL_LOG} 2>&1 &
    LOG INFO "Waiting service to start complete ..."

    wait_for_startstop start 20
    if [ $? -eq 0 ]; then
        LOG INFO "service start success"
        return 0
    else
        LOG ERROR "service start exceeded over 20s" >&2
        return 1
    fi
}


stop(){
    local p=""
    if [ -f ${PID_FILE_PATH} ]; then
        local pid_in_file=`cat ${PID_FILE_PATH} 2>/dev/null`
        if [ "x"${pid_in_file} !=  "x" ]; then
          p=`${JPS} -q | grep ${pid_in_file} | awk '{print $1}'`
        fi
    else
         p=`${JPS} -l | grep "${MAIN_CLASS}" | awk '{print $1}'`
    fi

    if [ -z "${p}" ]; then
        LOG INFO "service didn't start successfully, not found in the java process table"
        return 0
    fi
    LOG INFO "Killing service (pid ${p}) ..."
    kill  "${p}"  #kill -SIGTERM pid
    LOG INFO "Waiting service to stop complete ..."


    wait_for_startstop stop 20
    if [ $? -eq 0 ]; then
        LOG INFO "service stop success"
        return 0
    else
        LOG ERROR "service stop exceeded over 20s" >&2
        return 1
    fi
}

###########################
case ${!OPTIND} in
  start)
        start
  ;;
  stop)
        stop
  ;;
  status)
        check_status ${MAIN_CLASS}
        if [ $? -eq 0 ]; then
                 echo  "service  started !"
        else
                 echo  "service  stopped !!!"
        fi
        exit 0
  ;;
  *)
    usage
  ;;
esac
