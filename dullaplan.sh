#!/bin/bash
#### SETUP ############################################################
set -o errexit
set -o errtrace
set -o nounset

# Constants
CONFS=(/Library/Application\ Support/CrashPlan \
_HOME_/Library/Application\ Support/CrashPlan \
/usr/local/crashplan \
/var/lib/crashplan)

# Revert function and traps
revert_config () {
    [[ -n "${local_config:-}" ]] || return
    if [[ -f "${local_config}.bak" ]]
    then
        mv -f "${local_config}.bak" "${local_config}"
    fi
}

trap '_es=${?};
    _lo=${LINENO};
    _co=${BASH_COMMAND};
    revert_config;
    echo "${0}: line ${_lo}: \"${_co}\" exited with a status of ${_es}";
    exit ${_es}' ERR

trap 'es=${?}; revert_config; exit ${es}' INT TERM EXIT

PROG="${0##*/}"
USAGE="
Usage:  ${PROG} REMOTE_HOST

Automates local config file update and port forward for connecting to a
headless Crashplan server. See: https://github.com/TimZehta/dullaplan

Options:
    -h  show this help message and exit
"


#### FUNCTIONS ########################################################


error_exit() {
    # Display error message and exit
    local _es _msg
    _msg=${1}
    _es=${2:-1}
    echo "ERROR: ${_msg}" 1>&2
    exit ${_es}
}


help_print() {
    # Print help/usage, then exit (incorrect usage should exit 2)
    local _es=${1:-0}
    echo "${USAGE}"
    exit ${_es}
}


help_request_check() {
    # Print Help/Usage if requested
    local _arg
    shopt -s nocasematch
    # only accept help "action" in 1st position
    [[ "${1:-}" == 'help' ]] && help_print
    # evaulate all positional parameters for help options
    for _arg in "${@}"
    do
        case "${_arg}" in
            -h | -help | --help ) help_print
        esac
    done
    shopt -u nocasematch
    return 0
}


find_remote_config() {
    local _conf _remote_config _remote_home _remote_host
    _remote_host="${1}"
    _remote_home="$(sudo -u ${SUDO_USER} ssh -qtx ${_remote_host} \
        'echo "${HOME}"' | col -bp)"
    # Find remote .ui_info
    IFS=$'\n'
    for _conf in ${CONFS[@]}
    do
        _conf="${_conf/_HOME_/${_remote_home}}"
        _remote_config="$(sudo -u ${SUDO_USER} ssh -qtx ${_remote_host} \
            "find ${_conf} -type f -name .ui_info 2>/dev/null" | col -bp)"
        [[ -n "${_remote_config}" ]] && break
    done
    unset IFS
    if [[ -z "${_remote_config}" ]]
    then
        error_exit 'unable to find remote .ui_info config file'
    else
        echo "${_remote_config}"
    fi
}


find_local_config() {
    local _conf _local_config
    # Find local .ui_info
    IFS=$'\n'
    for _conf in ${CONFS[@]}
    do
        _conf="${_conf/_HOME_/${HOME}}"
        [[ -d "${_conf}" ]] || continue
        _local_config="$(find ${_conf} -type f -name .ui_info 2>/dev/null \
            || true)"
        [[ -n "${_local_config}" ]] && break
    done
    unset IFS
    if [[ -z "${_local_config}" ]]
    then
        error_exit 'ERROR: unable to find local .ui_info config file'
    else
        echo "${_local_config}"
    fi
}


backup_config () {
    [[ -n "${local_config:-}" ]] || return
    if [[ -f "${local_config}" ]]
    then
        cp -an "${local_config}" "${local_config}.bak"
    fi
    echo "    local_backup:      ${local_config}.bak"
}


#### MAIN #############################################################

# Invocation checks
help_request_check "${@:-}"
if (( ${#} == 0 ))
then
   echo 'ERROR: must specify REMOTE_HOST:' 1>&2
   help_print 2
fi
if (( ${#} > 1 ))
then
   echo 'ERROR: invalid parameters. Specify only a single REMOTE_HOST:' 1>&2
   help_print 2
fi
if (( ${UID} != 0 ))
then
    error_exit 'Must be root (invoke with sudo)'
fi

remote_host="${1}"
remote_config="$(find_remote_config "${remote_host}")"
remote_auth_token=$(sudo -u ${SUDO_USER} ssh -qtx ${remote_host} \
    "awk -F, '{print \$2}' \"${remote_config}\"" | col -bp)
local_config="$(find_local_config)"

echo
echo 'Parameters:'
echo "    remote_host:       ${remote_host}"
echo "    remote_config:     ${remote_config}"
echo "    remote_auth_token: ${remote_auth_token}"
echo "    local_config:      ${local_config}"

backup_config

echo "4200,${remote_auth_token},127.0.0.1" > "${local_config}"

echo
echo 'Creating SSH Tunnel...'
echo '    Close this connection to revert local config'
echo
sudo -u ${SUDO_USER} ssh -NTx -L 4200:localhost:4243 brick
