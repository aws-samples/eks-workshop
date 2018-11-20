---
title: "Test MySQL"
date: 2018-08-07T08:30:11-07:00
weight: 25
---
You can use **mysql-client** to send some data to the master, **mysql-0.mysql**
by following command.
```
kubectl run mysql-client --image=mysql:5.7 -i --rm --restart=Never --\
  mysql -h mysql-0.mysql <<EOF
CREATE DATABASE test;
CREATE TABLE test.messages (message VARCHAR(250));
INSERT INTO test.messages VALUES ('hello, from mysql-client');
EOF

```
Run the following to test slaves (mysql-read) received the data.
```
kubectl run mysql-client --image=mysql:5.7 -it --rm --restart=Never --\
  mysql -h mysql-read -e "SELECT * FROM test.messages"
```
The output should look like this.
```
+--------------------------+
| message                  |
+--------------------------+
| hello, from mysql-client |
+--------------------------+
```
To test load balancing across slaves, run the following command.
```
kubectl run mysql-client-loop --image=mysql:5.7 -i -t --rm --restart=Never --\
   bash -ic "while sleep 1; do mysql -h mysql-read -e 'SELECT @@server_id,NOW()'; done"
```
Each MySQL instance is assigned a unique identifier, and it can be retrieved using @@server_id. It will print the server id serving the request and the timestamp.
```
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         102 | 2018-11-14 12:44:57 |
+-------------+---------------------+
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         101 | 2018-11-14 12:44:58 |
+-------------+---------------------+
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         100 | 2018-11-14 12:44:59 |
+-------------+---------------------+
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         100 | 2018-11-14 12:45:00 |
+-------------+---------------------+
+-------------+---------------------+
| @@server_id | NOW()               |
+-------------+---------------------+
|         101 | 2018-11-14 12:45:01 |
+-------------+---------------------+
```
Leave this open in a separate window while you test failure in the next section.
