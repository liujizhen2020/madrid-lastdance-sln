#!/bin/bash
if [ "$#" -ne "2" ]
then
	echo "Error Param Number: example ./deploy.sh 180 mac-central-ctrl";
	exit -1;
fi
REMOTE_IP=$1
INSTANCT_NAME=$2
SSH_PORT=22
bee pack -be GOOS=linux -exs=.go:.DS_Store:.tmp:.sh:.ini:.conf
echo "REMOTE_IP:$REMOTE_IP"
echo "INSTANCE_NAME:$INSTANCT_NAME"
scp -P $SSH_PORT mac-central-ctrl.tar.gz root@$REMOTE_IP:/home/wwwroot/$INSTANCT_NAME
ssh -p $SSH_PORT root@$REMOTE_IP "cd /home/wwwroot/$INSTANCT_NAME; tar -zxvf mac-central-ctrl.tar.gz; supervisorctl restart $INSTANCT_NAME"
echo done!