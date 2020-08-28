---
title: "Setup multibranch projects"
date: 2018-08-07T08:30:11-07:00
weight: 40
draft: false
---

After logging into the Jenkins web console, we're ready to add our `eksworkshop-app` repository. Start by selecting `New Item` on the top right corner.

![Jenkins Login](/images/jenkins/jenkins-newitem.png)

Set the name of the item to `codecommit` and select the `AWS Code commit` item type.

![CodeCommit Item](/images/jenkins/jenkins-codecommititem.png)

Execute the following commands to get your Git username and password.

```
echo $GIT_USERNAME
echo $GIT_PASSWORD
```

To the right of `Code Commit Credentials`, select `Add` then `CodeCommit`. Set the `Username` and `Password` to the corresponding values from the previous command.

![Jenkins CodeCommit Credentials](/images/jenkins/jenkins-gitcredentials.png)

Confirm your current AWS Region.

```
echo https://codecommit.$AWS_REGION.amazonaws.com
```
Copy that value to the`URL` field under project.

![Jenkins Project Config](/images/jenkins/jenkins-projectsetup.png)

Select `Save` at the bottom left of the screen. Jenkins will begin executing the pipelines in repositories and branches that contain a `Jenkinsfile`.

![Master Branch Pipeline](/images/jenkins/jenkins-eksworkshop-app-master.png)
