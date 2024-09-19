#!/bin/bash

usage() { echo "Usage: $0 [-u username] login/status/start/stop/startall/stopall/clstart/clstop" 2>&1; exit 1; }

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


login_func () {
      echo 'Logging in to aws...'
      aws sso login --profile $prof;aws sts get-caller-identity --profile $prof
      exit
}

status_func () {
      echo 'Retrieving list of EC2 instances for '$user'...'
      aws ec2 describe-instances --filters Name=tag:user,Values="$user" --query "Reservations[*].Instances[*].{Name:Tags[?Key=='Name']|[0].Value,Instance:State.Name}" --output table
      exit
}

single_pre_func () {
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
}

all_func () {
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
}

single_func () {
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
}

cluster_func () {
    # Run the aws ec2 command to find the names of running or stopped instances for the user and write this to a tmp file
    n=0

    aws ec2 describe-instances --filters Name=instance-state-name,Values=$state Name=tag:user,Values="$user" --query 'Reservations[*].Instances[*].{Instance:InstanceId,Name:Tags[?Key=='Name']|[0].Value,Name:Tags[?Key=='\''Name'\'']|[0].Value}' --output text | awk '{print $2, $1}' | sort | awk '{a[$1]=a[$1] " " $2} END {for (i in a) print i, a[i]}' > $$tmp

    # Process the tmp file to get a numbered list for selection latter for the start and stop commands
    while read line; do
        n=$((n+1))
        eval "line${n}=\$line"
        shortline=$(echo $line | awk '{print $1}')
        printf "[%s] %s\n" "$n" "$shortline"
    done < $$tmp

    # remove the tmp file
    rm -f $$tmp

    # Check if there are no running or stopped instances and exit
    if [ "$n" -eq 0 ]
    then
        echo >&2 No $state instances found.
        exit
    fi

    printf 'Enter Index ID for instance to %s (1 to %s): ' "$1" "$n"
    read -r num
    num=$(printf '%s\n' "$num" | tr -dc '[:digit:]')

    if [ "$num" -le 0 ] || [ "$num" -gt "$n" ]
    then
        echo >&2 Incorrect selection.
        exit 1
    else
        eval "LIN=\$line${num}"
        inst=$(echo $LIN | cut -f 2- -d ' ')
        echo -e $newstate instance\(s\) $inst
	# output text looks nicer for clusters
        aws ec2 $ec2cmd --instance-ids $inst --output text
    fi
}




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
        login_func
      ;;
    status)
        status_func
      ;;
    start)
      echo 'Retrieving list of stopped EC2 instances for '$user'...'
      echo 'Which EC2 instance do you wish to start?'
      state='stopped'
      ec2cmd='start-instances'
      newstate='Starting'
      single_pre_func
      single_func
      ;;
    stop)
      echo 'Retrieving list of running EC2 instances for '$user'...'
      echo 'Which EC2 instance do you wish to stop?'
      state='running'
      ec2cmd='stop-instances'
      newstate='Stopping'
      single_pre_func
      single_func
      ;;
    startall)
      echo 'Retrieving list of stopped EC2 instances for '$user'...'
      echo 'Start all of these instances?'
      state='stopped'
      ec2cmd='start-instances'
      newstate='Starting all'
      single_pre_func
      all_func
      ;;
    stopall)
      echo 'Retrieving list of running EC2 instances for '$user'...'
      echo 'Stop all of these instances?'
      state='running'
      ec2cmd='stop-instances'
      newstate='Stopping all'
      single_pre_func
      all_func
      ;;
    clstart)
      echo 'Retrieving list of stopped clusters for '$user'...'
      echo 'Which cluster do you wish to start?'
      state='stopped'
      ec2cmd='start-instances'
      newstate='Starting'
      cluster_func
      ;;
    clstop)
      echo 'Retrieving list of running clusters for '$user'...'
      echo 'Which cluster do you wish to stop?'
      state='running'
      ec2cmd='stop-instances'
      newstate='Stopping'
      cluster_func
      ;;
    *)
      usage
      exit
      ;;
esac
