#!/bin/bash

usage() { echo "Usage: $0 [-u username] status/start/stop" 2>&1; exit 1; }

while getopts "u:h:" o; do
    case "${o}" in
        u)
            user=${OPTARG}
            ;;
        h)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ x"$user" == x ]
then
    user=$(grep ^shared_handle ~/.automaton.conf  | awk '{print $3}')
fi

case $1 in
    status)
      echo 'Retrieving list of EC2 instances for '$user'...'
      aws ec2 describe-instances --filters Name=tag:user,Values="$user" --query "Reservations[*].Instances[*].{Name:Tags[?Key=='Name']|[0].Value,Instance:State.Name}" --output table
      exit
      ;;
    start)
      echo 'Retrieving list of stopped EC2 instances for '$user'...'
      echo 'Which EC2 instance do you wish to start?'
      state='stopped'
      ec2cmd='start-instances'
      newstate='Starting'
      ;;
    stop)
      echo 'Retrieving list of running EC2 instances for '$user'...'
      echo 'Which EC2 instance do you wish to stop?'
      state='running'
      ec2cmd='stop-instances'
      newstate='Stopping'
      ;;
    *)
      usage
      exit
      ;;
esac

n=0
aws ec2 describe-instances --filters Name=instance-state-name,Values=$state Name=tag:user,Values="$user" --query "Reservations[*].Instances[*].{Instance:InstanceId,AZ:Placement.AvailabilityZone,Name:Tags[?Key=='Name']|[0].Value}" --output text > $$tmp
while read line; do
    n=$((n+1))
    printf "[%s] %s\n" "$n" "$line"
    eval "line${n}=\$line"
done < $$tmp
rm -f $$tmp

if [ "$n" -eq 0 ]
then
    echo >&2 No $state instances found.
    exit
fi

printf 'Enter Index ID for instance to stop (1 to %s): ' "$n"
read -r num
num=$(printf '%s\n' "$num" | tr -dc '[:digit:]')

if [ "$num" -le 0 ] || [ "$num" -gt "$n" ]
then
    echo >&2 Incorrect selection.
    exit 1
else
    eval "LIN=\$line${num}"
    inst=$(echo $LIN | awk '{print $2}')
    echo $newstate instance $inst
    aws ec2 $ec2cmd --instance-ids $inst --output table
fi

