REMOTE_IP=$1

function help()
{
    cat << HELP
usage: cpcode.sh <IP address>

Copy all changes visible under www_common to /www under target machine
This script should be excuted directly under branches|trunk directory
HELP
}

function error()
{
    code=$1

    if [ $1 = 'ARG' ]; then
        echo "The script need at least 1 argument"
    elif [ $1 = 'IP' ]; then
        echo "Invalid IP address"
    elif [ $1 = 'DIR']; then
        echo "Run this command directly under branches|trunk"
    fi

    help
    exit 1
}

if [ x$1 = 'xhelp' ]; then
    help
    exit 0
elif [ -z $1 ]; then
    error 'ARG'
fi

ipcalc -n $1 | grep INVALID && valid=0 || valid=1

if [ $valid -eq 0 ]; then
    error 'IP'
fi

cd rms/php/www_common

if [ $? -ne 0 ]; then
    error 'DIR'
fi

mapfile -t paths < <( svn st | grep "^[^\\?]" | awk '{print $2}' )

for i in "${paths[@]}"
do
    echo $i
    sshpass -p 1234 scp -P2222 ${i} root@${REMOTE_IP}:/www/${i}
done

#sshpass -p 1234 scp -P2222 rms/php/www_common/rpc_backend/LUN.php root@${REMOTE_IP}:/www/rpc_backend/
