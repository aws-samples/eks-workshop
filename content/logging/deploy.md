---
title: "Deploy Fluentd"
date: 2018-08-07T08:30:11-07:00
weight: 30
---

```
mkdir ~/environment/fluentd
cd ~/environment/fluentd
wget https://eksworkshop.com/onug/logging/deploy.files/fluentd.yml
```
Explore the fluentd.yml to see what is being deployed. There is a link at the bottom of this page. The Fluentd log agent configuration is located in the Kubernetes ConfigMap. Fluentd will be deployed as a DaemonSet, i.e. one pod per worker node. In our case, a 3 node cluster is used and so 3 pods will be shown in the output when we deploy.

```
kubectl apply -f ~/environment/fluentd/fluentd.yml
```

Watch for all of the pods to change to running status

```
kubectl get pods -w --namespace=kube-system
```

We are now ready to check that logs are arriving in [CloudWatch Logs](https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#logStream:group=/eks/eksworkshop-eksctl/containers)


{{%attachments title="Related files" pattern=".yml"/%}}




