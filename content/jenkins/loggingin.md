---
title: "Logging In"
weight: 30
---
Before we can log in, we need to retrieve the admin password from the *kubernetes secret store*
```
printf $(kubectl get secret --namespace default cicd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
```

The output of this command will give you the default password for your *admin*
user. Log into the *jenkins* login screen using these credentials.

In another window, navigate to the ELB address of your *jenkins* instance.

![Jenkins Login](/images/jenkins-login.png)

From here we can log in using:

| Username | Password             |
|----------|----------------------|
| admin    | *command from below* |
