PASS=""
while getopts "p:" opt; do
    case "$opt" in
        p)
            PASS=$OPTARG
            ;;
    esac
done
shift $((OPTIND-1))

IP1=$1
IP2=$2

if [ "x${PASS}" = "x" ]; then
    PASS="1234"
fi

sshpass -p $PASS ssh root@${IP1} "mount /dev/boot1 /mnt"
sshpass -p $PASS scp initrd.gz initrd_nv.tgz kernel root@${IP1}:/mnt/boot/
sshpass -p $PASS ssh root@${IP1} "umount /mnt"

if [ "x${IP2}" != "x" ]; then
    sshpass -p $PASS ssh root@${IP2} "mount /dev/boot1 /mnt"
    sshpass -p $PASS scp initrd.gz initrd_nv.tgz kernel root@${IP2}:/mnt/boot/
    sshpass -p $PASS ssh root@${IP2} "umount /mnt"
fi
