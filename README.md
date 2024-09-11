# ec2status
The ec2.sh script is used to start, stop, or get the status of EC2 instances from a command line.
The command will retrieve the user name from the ~/.automaton.conf file. This can be overridden using the -u parameter.

Usage: ec2.sh [-u username] login/status/start/stop/startall/stopall

Example output:
```
$ ./ec2.sh stop
Retrieving list of running EC2 instances for peter.gilroy...
Which EC2 instance do you wish to stop?
[1] us-west-2c  i-xxxxxxxxxxxxxxxxx     peter.gilroy_test
Enter Index ID for instance to stop (1 to 1): 1
Stopping instance i-xxxxxxxxxxxxxxxxx
---------------------------
|      StopInstances      |
+-------------------------+
||   StoppingInstances   ||
|+-----------------------+|
||      InstanceId       ||
|+-----------------------+|
||  i-xxxxxxxxxxxxxxxxx  ||
|+-----------------------+|
|||    CurrentState     |||
||+-------+-------------+||
||| Code  |    Name     |||
||+-------+-------------+||
|||  64   |  stopping   |||
||+-------+-------------+||
|||    PreviousState    |||
||+--------+------------+||
|||  Code  |   Name     |||
||+--------+------------+||
|||  16    |  running   |||
||+--------+------------+||
```

With -u parameter:

```
$ ./ec2.sh -u support_team stop
Retrieving list of running EC2 instances for support_team...
Which EC2 instance do you wish to stop?
[1] us-west-2a  i-xxxxxxxxxxxxxxxxx     support_team_dse68dc1
[2] us-west-2a  i-xxxxxxxxxxxxxxxxx     support_team_dse68dc1
[3] us-west-2a  i-xxxxxxxxxxxxxxxxx     support_team_dse68dc1
[4] us-west-2a  i-xxxxxxxxxxxxxxxxx     support_team_dse68dc1
...
[33] us-west-2a i-xxxxxxxxxxxxxxxxx     support_team_cassmon
Enter Index ID for instance to stop (1 to 33):
...
```
