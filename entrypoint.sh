#!/bin/bash

# Following Google Shell Style Guide: https://google.github.io/styleguide/shell.xml

[[ $DEBUG == true ]] && set -x

# NFS options
RO_OPTIONS="${RO_OPTIONS:-nfsvers=3,nolock,ro}"
RW_OPTIONS="${RW_OPTIONS:-nfsvers=3,tcp,hard,intr,nolock,timeo=600,retrans=2}"

###############################################################################
#       Functions
###############################################################################

err() {
	echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}



# This is a freeking awesome routine from Rancher: https://github.com/rancher/storage/blob/master/package/nfs/rancher-nfs
ismounted() {
    local mountPoint=$1
    local mountP=$(findmnt -n ${mountPoint} 2>/dev/null | cut -d' ' -f1)
    if [ "${mountP}" == "${mountPoint}" ]; then
        echo "1"
    else
        echo "0"
    fi
}

_rsync() {
    SRC=$1
    DST=$2
    if [[ ! -d ${SRC} ]]
    then
        err "Source directory ${SRC} is missing!!! Bailing!!!"
        exit 2
    fi
    if [[ ! -d ${DST} ]]
    then
        err "Destination directory ${DST} is missing!!! Bailing!!!"
        exit 2
    fi
    echo "Starting rsync of ${SRC} to ${DST}"
    (rsync -auvv --progress --exclude=.etc ${SRC}/ ${DST}/ )
}

mount_dirs() {
    if [[ ! -d ${OLDLOCAL} ]]; then
        mkdir -p ${OLDLOCAL}
    else
        echo "${OLDLOCAL} already exists.. skipping"
    fi

    if [[ ! -d ${NEWLOCAL} ]]; then
        mkdir -p ${NEWLOCAL}
    else
        echo "${NEWLOCAL} already exists.. skipping"
    fi

    if [ $(ismounted "${OLDLOCAL}" ) == 0 ] ; then
        echo "Mounting ${OLDLOCAL}"
        if !  (mount -o ${RO_OPTIONS} ${OLDNAS}:${OLDREMOTE} ${OLDLOCAL} ); then
            echo "Failed to mount ${OLDNAS}:${OLDREMOTE} as ${OLDLOCAL}"
            exit 2
        fi
    else
        echo "${OLDNAS}:${OLDREMOTE} is already mounted as ${OLDLOCAL}"

    fi

    if [ $(ismounted "${NEWLOCAL}") == 0 ] ; then
        echo "Mounting ${NEWLOCAL}"
        if ! (mount -o ${RW_OPTIONS} ${NEWNAS}:${NEWREMOTE} ${NEWLOCAL}); then
            echo "Failed to mount ${NEWNAS}:${NEWREMOTE} as ${NEWLOCAL}"
            exit 2
        fi
    else
        echo "${NEWNAS}:${NEWREMOTE} is already mounted as ${NEWLOCAL}"
    fi
}

usage() {
  echo "";
  echo "Usage: entrypoint.sh SYSNAME:FS:[SLEEP]";
  echo "SYSNAME = Name used to identify the collection of mounts being moved.";
  echo "FS = An identifier used to select the mount being moved eg: sys1p_data";
  echo "SLEEP = number of minutes to sleep between runs.";
  echo " If the SLEEP value is not provided it defaults to 0 (single run)";
  echo " Any positive value will result in the rsync process syncing data in a loop, sleeping ${SLEEP} minutes between runs.";
  echo "";
  exit 1;

}

d="${@}"
for data in "${d[@]}"; do
    SYSNAME=$(echo $data | awk -F':' '{ print $1}')
    FS=$(echo $data | awk -F':' '{ print $2}')
    SLEEP=$(echo $data | awk -F':' '{ print $3 }')
    SYSNAME_JSON="/tmp/${SYSNAME}.json"
    [[ -z "${SYSNAME}" ]] &&  usage
    [[ -z "${FS}" ]] && usage
    [[ -z "${SLEEP}" ]] && SLEEP=0
    
done

case ${SYSNAME} in 
    maint)
        echo "set nohlsearch" > ~/.vimrc
        echo "set paste" >> ~/.vimrc
        echo "set autoindent" >> ~/.vimrc
        echo "set backspace=indent,eol,start" >> ~/.vimrc
        echo "set tabstop=4" >> ~/.vimrc
        echo "set expandtab" >> ~/.vimrc
        echo "set shiftwidth=4" >> ~/.vimrc
        echo "set shiftround" >> ~/.vimrc
        echo "set matchpairs+=<:>" >> ~/.vimrc
        echo "set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<" >> ~/.vimrc
        echo "syntax enable" >> ~/.vimrc
        echo "set smartindent" >> ~/.vimrc
        echo "syntax on" >> ~/.vimrc
        echo "filetype plugin indent on" >> ~/.vimrc
    ;;
    ${SYSNAME})
        if [ -f ${SYSNAME_JSON} ]; then
            JQ=$(<${SYSNAME_JSON})
        else
            usage
        fi

        # The jq command returns a string literal called null.
        # Check to make sure there is a valid fs identifier before trying to mount anything.
        # Bail noisily if nothing exists.
        FSTEST=$(echo ${JQ} | jq -r .mounts.${FS})
        if [ "${FSTEST}" == "null" ]; then
	    echo "The File system identifier ${FS} is not a valid option, bailing" 
            exit 1
        fi
        OLDNAS=$(echo ${JQ} | jq -r .nas.old.name)
        OLDREMOTE=$(echo ${JQ} | jq -r .mounts.${FS}.old.remote)
        OLDLOCAL=$(echo ${JQ} | jq -r .mounts.${FS}.old.local)
        NEWNAS=$(echo ${JQ} | jq -r .nas.new.name)
        NEWREMOTE=$(echo ${JQ} | jq -r .mounts.${FS}.new.remote)
        NEWLOCAL=$(echo ${JQ} | jq -r .mounts.${FS}.new.local)
    ;;
esac


case ${FS} in
        shell)
		/bin/bash
	;;
	${FS})
		mount_dirs
		if [ "${SLEEP}" == 0 ]; then
			_rsync ${OLDLOCAL} ${NEWLOCAL}
            umount ${OLDLOCAL} 
            umount ${NEWLOCAL}
		else
			s=$((${SLEEP} * 60))
			while true
			do
				_rsync ${OLDLOCAL} ${NEWLOCAL}
				echo "Sleeping ${s} seconds..."
				sleep ${s}
			done
		fi
	;;
	*)
		err "No valid filesystem ${FS} provided"
		exit 2
	;;
esac
