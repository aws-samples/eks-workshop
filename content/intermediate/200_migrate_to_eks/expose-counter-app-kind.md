---
title: "Expose counter app from kind"
weight: 30
---

An app that's not exposed isn't very useful.
To seed the database with information, we will port-forward to the PostgreSQL database, using AWS-SessionManager. This works because the Cloud9 instance already has the relevant IAM permissions assigned to it, as this is how the Cloud9 browser client functions in the background.

On your **local** terminal, run the following:

```bash
aws ssm start-session \
    --target $(aws ec2 describe-instances --filters Name=tag:Name,Values=*cloud9-eksworkshop* --query Reservations[0].Instances[0].InstanceId --output text) \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters '{"host":["localhost"],"portNumber":["30000"], "localPortNumber":["30000"]}'
```

You should see a message in the terminal such as:

```
Starting session with SessionId: ______________-0998241f466c70fbb
Port 30000 opened for sessionId ______________-0998241f466c70fbb.
Waiting for connections...
```

You can host open http://localhost:30000/ on your local machine and view the application directly in your browser.

Make sure you click the button a lot because that's the important data we're going to migrate to EKS later.

![counter app screenshot](/images/migrate_to_eks/counter-app.gif)
