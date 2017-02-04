#!/bin/sh
### BEGIN INIT INFO
# Provides:
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       Enable service provided by daemon.
### END INIT INFO

## Source function library.
. /etc/rc.d/init.d/functions
# Source LSB function library.
if [ -r /lib/lsb/init-functions ]; then
        . /lib/lsb/init-functions
else
    exit 1
fi

DISTRIB_ID=`lsb_release -i -s 2>/dev/null`
NAME="$(basename $0)"

# Get application specific config file
if [ -r "/etc/sysconfig/${NAME}" ]; then
    . /etc/sysconfig/${NAME}
fi

# Define the lockfile and pidfile and process string
LOCKFILE="${LOCKFILE:-/var/lock/subsys/${NAME}}"
PIDFILE="${PIDFILE:-/var/run/${NAME}}"

dir=""
cmd=""
user=""

stdout_log="/var/log/$name/$name.log"
stderr_log="/var/log/$name/$name.err"


function _pidof() {
    local kpid=""
    kpid=$(/usr/bin/pgrep -f -d , -u $name) 2>/dev/null
    if [ -z "$kpid" ]; then
        echo $kpid
    else
        echo $kpid | tee $pid_file
    fi
}

get_pid() {
    local _pid=$(_pidof)
    echo $_pid
}

is_running() {
    [ -f "$pid_file" ] && ps `get_pid` > /dev/null 2>&1
}

function parseOptions() {
    options=""
    if [ -r "/etc/sysconfig/${NAME}" ]; then
        options="$options $(
                     awk '!/^#/ && !/^$/ { ORS=" ";
                                           print "export ", $0, ";" }' \
                     /etc/sysconfig/${NAME}
                 )"
    fi
    CMD="${CMD} $options"
}

start() {
    retval=0
    echo -n "Starting ${CMD} 
    if is_running; then
        echo "Already started"
    else
        echo "Starting $NAME"
        cd "$dir"
        if [ -z "$user" ]; then
            sudo $cmd >> "$stdout_log" 2>> "$stderr_log" &
        else
            sudo -u "$user" $cmd >> "$stdout_log" 2>> "$stderr_log" &
        fi
        echo $! > "$pid_file"
        if ! is_running; then
            echo "Unable to start, see $stdout_log and $stderr_log"
            exit 1
        fi
    fi
}

stop() {
    if is_running; then
        echo -n "Stopping $name.."
        kill `get_pid`
        for i in {1..10}
        do
            if ! is_running; then
                break
            fi

            echo -n "."
            sleep 1
        done
        echo

        if is_running; then
            echo "Not stopped; may still be shutting down or shutdown may have failed"
            exit 1
        else
            echo "Stopped"
            if [ -f "$pid_file" ]; then
                rm "$pid_file"
            fi
        fi
    else
        echo "Not running"
    fi
}

restart() {

}

status() {

}


case "$1" in
    start)
        start
        ;;
    stop)
        stop
    ;;
    restart)
        $0 stop
        sleep 5
        $0 start
        ;;
    status)
        if is_running; then
            echo "Running"
        else
            echo "Stopped"
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac

exit 0
