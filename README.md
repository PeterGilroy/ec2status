# ec2status
The ec2.sh script is used to start or stop EC2 instances from a command line.
The command will retrieve the user name form the ~/.automaton.conf file. This can be overridden using the -u parameter.

Usage: ec2.sh [-u username] start/stop

Example output:
```$ ./ec2.sh stop
Retreiving list of running EC2 instances for peter.gilroy...
Which EC2 instance do you wish to stop?
[1] us-west-2c  i-0abf0ea057f3b4504     peter.gilroy_test
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

```$ ./ec2.sh -u support_team stop
Retreiving list of running EC2 instances for support_team...
Which EC2 instance do you wish to stop?
[1] us-west-2a  i-xxxxxxxxxxxxxxxxx     support_team_dse68dc1
[2] us-west-2a  i-xxxxxxxxxxxxxxxxx     support_team_dse68dc1
[3] us-west-2a  i-xxxxxxxxxxxxxxxxx     support_team_dse68dc1
[4] us-west-2a  i-xxxxxxxxxxxxxxxxx     support_team_dse68dc1
[5] us-west-2a  i-xxxxxxxxxxxxxxxxx     support_team_opsc68
[6] us-west-2a  i-xxxxxxxxxxxxxxxxx     support_team_auth
[7] us-west-2a  i-xxxxxxxxxxxxxxxxx     support_team_dse68dc2
[8] us-west-2a  i-xxxxxxxxxxxxxxxxx     support_team_dse68dc2
[9] us-west-2a  i-xxxxxxxxxxxxxxxxx     support_team_dse68dc2
[10] us-west-2a i-xxxxxxxxxxxxxxxxx     support_team_monitor
[11] us-west-2a i-xxxxxxxxxxxxxxxxx     support_team_cfssl
[12] us-west-2a i-xxxxxxxxxxxxxxxxx     support_team_matserver
[13] us-west-2b i-xxxxxxxxxxxxxxxxx     support_team_ossupgrade
[14] us-west-2b i-xxxxxxxxxxxxxxxxx     support_team_ossupgrade
[15] us-west-2b i-xxxxxxxxxxxxxxxxx     support_team_ossupgrade
[16] us-west-2b i-xxxxxxxxxxxxxxxxx     support_team_ossupgrade
[17] us-west-2b i-xxxxxxxxxxxxxxxxx     support_team_ossupgrade
[18] us-west-2b i-xxxxxxxxxxxxxxxxx     support_team_ossupgrade
[19] us-west-2b i-xxxxxxxxxxxxxxxxx     support_team_cass4
[20] us-west-2b i-xxxxxxxxxxxxxxxxx     support_team_cass4
[21] us-west-2b i-xxxxxxxxxxxxxxxxx     support_team_cass4
[22] us-west-2b i-xxxxxxxxxxxxxxxxx     support_team_oss404
[23] us-west-2b i-xxxxxxxxxxxxxxxxx     support_team_oss404
[24] us-west-2b i-xxxxxxxxxxxxxxxxx     support_team_oss404
[25] us-west-2a i-xxxxxxxxxxxxxxxxx     support_team_dse51
[26] us-west-2a i-xxxxxxxxxxxxxxxxx     support_team_dse51
[27] us-west-2a i-xxxxxxxxxxxxxxxxx     support_team_dse51
[28] us-west-2a i-xxxxxxxxxxxxxxxxx     support_team_dse51
[29] us-west-2a i-xxxxxxxxxxxxxxxxx     support_team_docker
[30] us-west-2a i-xxxxxxxxxxxxxxxxx     support_team_dse51scb
[31] us-west-2a i-xxxxxxxxxxxxxxxxx     support_team_dse51scb
[32] us-west-2a i-xxxxxxxxxxxxxxxxx     support_team_dse51scb
[33] us-west-2a i-xxxxxxxxxxxxxxxxx     support_team_cassmon
Enter Index ID for instance to stop (1 to 33):
...
```
