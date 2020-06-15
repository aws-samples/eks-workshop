---
title: "Logging In"
date: 2018-08-07T08:30:11-07:00
weight: 30
draft: false
---

Now that we have the ELB address of your `jenkins` instance we can go an
navigate to that address in another window.

![Jenkins Login](/images/jenkins-login.png)

From here we can log in using:

| Username | Password             |
|----------|----------------------|
| admin    | `command from below` |


```
printf $(kubectl get secret --namespace default cicd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
```

The output of this command will give you the default password for your `admin`
user. Log into the `jenkins` login screen using these credentials.
