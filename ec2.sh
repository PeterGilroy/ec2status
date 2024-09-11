#!/bin/bash

usage() { echo "Usage: $0 [-u username] login/status/start/stop/startall/stopall" 2>&1; exit 1; }

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

# The aws commands used only work if the AWS_PROFILE envvar is set
# check to see if it is set and set it to the configured profile if there is just one
# and prompt with a list of profiles if there is more than one.
if [ x"$AWS_PROFILE" == x ]
then
    echo 'AWS_PROFILE environment variable not set.';
    profs=$(aws configure list-profiles | grep -v default);
    if [[ $(echo $profs | wc -w) == 1 ]];
    then
        prof=$profs
        echo 'Setting AWS_PROFILE environment variable to '$prof'.';export AWS_PROFILE=$prof;
    else
        PS3='Which AWS profile do you wish to use?: '
        select opt in $profs Quit
        do
           case $prof in
              "Quit")
                  break
                  ;;
              *) echo 'Setting AWS_PROFILE environment variable to '$prof'.';export AWS_PROFILE=$prof;break;
           esac
        done
    fi
else 
    prof=$AWS_PROFILE
fi

# Get the user's name from the .automaton.conf file
if [ x"$user" == x ]
then
    user=$(grep ^shared_handle ~/.automaton.conf  | awk '{print $3}')
fi

# check for the command run and set parameters or perform actions
case $1 in
    login)
      echo 'Logging in to aws...'
      aws sso login --profile $prof;aws sts get-caller-identity --profile $prof
      exit
      ;;
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
    startall)
      echo 'Retrieving list of stopped EC2 instances for '$user'...'
      echo 'Start all of these instances?'
      state='stopped'
      ec2cmd='start-instances'
      newstate='Starting all'
      ;;
    stopall)
      echo 'Retrieving list of running EC2 instances for '$user'...'
      echo 'Stop all of these instances?'
      state='running'
      ec2cmd='stop-instances'
      newstate='Stopping all'
      ;;
    *)
      usage
      exit
      ;;
esac

# Run the aws ec2 command to find the names of running or stopped instances for the user and write this to a tmp file
n=0
aws ec2 describe-instances --filters Name=instance-state-name,Values=$state Name=tag:user,Values="$user" --query "Reservations[*].Instances[*].{Instance:InstanceId,AZ:Placement.AvailabilityZone,Name:Tags[?Key=='Name']|[0].Value}" --output text > $$tmp

# Process the tmp file to get a numbered list for selection latter for the start and stop commands
while read line; do
    n=$((n+1))
    printf "[%s] %s\n" "$n" "$line"
    eval "line${n}=\$line"
done < $$tmp

# Process the tmp file to get a list of all the instance ids that are running or stopped for the stopall and startall commands
instids=$(awk '{print $2}' $$tmp | tr -d '\r')

# remove the tmp file
rm -f $$tmp

# Check if there are no running or stopped instances and exit
if [ "$n" -eq 0 ]
then
    echo >&2 No $state instances found.
    exit
fi

# check if running stopall or startall
if [[ "$1" = stopall || "$1" = startall ]]
then
    echo $line
    read -p "Are you sure? " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo
        echo $newstate of the instances...
	# output text looks nicer for multiple instances
	aws ec2 $ec2cmd --instance-ids $instids --output text
    fi
    echo
    exit

# running start or stop so end up here
else
    printf 'Enter Index ID for instance to %s (1 to %s): ' "$1" "$n"
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
	# output table looks nicer for just one instance
        aws ec2 $ec2cmd --instance-ids $inst --output table
    fi
fi
