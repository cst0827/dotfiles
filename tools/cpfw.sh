#PASS=""
#while getopts "p:" opt; do
#    case "$opt" in
#        p)
#            PASS=$OPTARG
#            ;;
#    esac
#done
#shift $((OPTIND-1))
#
#IP1=$1
#IP2=$2
#
#if [ "x${PASS}" = "x" ]; then
#    PASS="1234"
#fi
#
#sshpass -p $PASS ssh -q -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no root@${IP1} "mount /dev/boot1 /mnt"
#sshpass -p $PASS scp -q -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no initrd.gz initrd_nv.tgz kernel root@${IP1}:/mnt/boot/
#sshpass -p $PASS ssh -q -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no root@${IP1} "umount /mnt"
#
#if [ "x${IP2}" != "x" ]; then
#    sshpass -p $PASS ssh -q -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no root@${IP2} "mount /dev/boot1 /mnt"
#    sshpass -p $PASS scp -q -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no initrd.gz initrd_nv.tgz kernel root@${IP2}:/mnt/boot/
#    sshpass -p $PASS ssh -q -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no root@${IP2} "umount /mnt"
#fi

#!/bin/sh

PASS=""
FAILED_IPS=""
SSH_OPTS="-q -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no"

usage() {
    echo "Usage: $0 [-p password] ip1 [ip2 ip3 ...]"
    exit 1
}

while getopts "p:" opt; do
    case "$opt" in
        p) PASS=$OPTARG ;;
        *) usage ;;
    esac
done
shift $((OPTIND - 1))

[ $# -ge 1 ] || usage

if [ "x$PASS" = "x" ]; then
    PASS="1234"
fi

for f in initrd.gz initrd_nv.tgz kernel; do
    if [ ! -f "$f" ]; then
        echo "File not found: $f"
        exit 1
    fi
done

run_ssh() {
    ip=$1
    cmd=$2
    sshpass -p "$PASS" ssh $SSH_OPTS "root@$ip" "$cmd"
}

run_scp() {
    ip=$1
    sshpass -p "$PASS" scp $SSH_OPTS \
        initrd.gz initrd_nv.tgz kernel \
        "root@$ip:/mnt/boot/"
}

copy_to_ip() {
    ip=$1

    echo "==> Start processing $ip"

    run_ssh "$ip" "mount /dev/boot1 /mnt" || {
        echo "[$ip] mount failed"
        return 1
    }

    run_scp "$ip" || {
        echo "[$ip] scp failed"
        run_ssh "$ip" "umount /mnt" >/dev/null 2>&1
        return 1
    }

    run_ssh "$ip" "umount /mnt" || {
        echo "[$ip] umount failed"
        return 1
    }

    echo "[$ip] success"
    return 0
}

for ip in "$@"; do
    copy_to_ip "$ip" || FAILED_IPS="$FAILED_IPS $ip"
done

if [ "x$FAILED_IPS" = "x" ]; then
    echo "All IPs completed successfully."
    exit 0
else
    echo "Failed IPs:$FAILED_IPS"
    exit 1
fi
