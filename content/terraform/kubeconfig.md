---
title: "Create Kubeconfig File"
date: 2018-08-07T13:07:50-07:00
weight: 40
draft: true
---
Now that we have the cluster running, we need to create the KubeConfig file that will be used to manage the cluster.

The terraform module stores the kubeconfig information in it's state store.
We can view it with this command:
```
terraform output kubeconfig
```
And we can save it for use with this command:
```
terraform output kubeconfig > ${HOME}/.kube/config-eksworkshop-tf
```

We now need to add this new config to the KubeCtl Config list:
```
export KUBECONFIG=${HOME}/.kube/config-eksworkshop-tf:${HOME}/.kube/config
echo "export KUBECONFIG=${KUBECONFIG}" >> ${HOME}/.bashrc
```
