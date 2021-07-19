---
title: "Compare with Amazon Linux 2"
date: 2021-07-14T00:00:00-03:00
weight: 200
---

Assuming you did not logout from the admin container, run the following command to get a full root shell in your Bottlerocket node

```
$ sudo sheltie
```

You are in a bash shell now and let us check the selinux status

```
# sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             fortified
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     denied
Memory protection checking:     actual (secure)
Max kernel policy version:      31
```

You can open a new terminal in your Cloud 9 environment which runs on Amazon Linux 2 and run the same to see that selinux is disabled by default.

```
$ sestatus 
SELinux status:                 disabled
```

Going back to the root shell of your Bottlerocket node, try checking the status of yum

```
# yum --version
bash: yum: command not found
```

Running the same command in Amazon Linux 2 should provide the version of yum installed with additional details. A package manager is not required as a full filesystem image will be used to update Bottlerocket versions instead of individual packages.

You can check the list of major of third-party components that are packaged in Bottlerocket from the [security section](https://github.com/bottlerocket-os/bottlerocket#security) in Github.

Let us clean up before moving to the next topic

```bash
eksctl delete nodegroup -f br-managed-ng.yaml --approve

rm user-data.txt
rm user-data-base64.txt
rm launch-template.json
rm br-managed-ng.yaml
```