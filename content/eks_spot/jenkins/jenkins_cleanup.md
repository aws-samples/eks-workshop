---
title: "Jenkins cleanup"
date: 2018-08-07T08:30:11-07:00
weight: 90
---

{{% notice note %}}
If you're running in an account that was created for you as part of an AWS event, there's no need to go through the cleanup stage - the account will be closed automatically.\
If you're running in your own account, make sure you run through these steps to make sure you don't encounter unwanted costs.
{{% /notice %}}

### Removing the Jenkins server
```
helm delete cicd
```

### Removing the Jenkins nodegroup
```
eksctl delete nodegroup -f spot_nodegroup_jenkins.yml --approve
```
