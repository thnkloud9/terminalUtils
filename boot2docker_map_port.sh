if [ $# -lt 3 ]; then
    echo "format: boot2docker_map_port.sh <rule name> <local_port> <remote_port>"
    exit 1
fi

NAME=$1
LOCAL=$2
REMOTE=$3

VBoxManage controlvm boot2docker-vm natpf1 "$NAME,tcp,127.0.0.1,$LOCAL,,$REMOTE"
