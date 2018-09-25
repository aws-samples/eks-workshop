---
title: "Create the Worker ConfigMap"
date: 2018-08-07T12:00:40-07:00
weight: 70
draft: true
---

The file found in the repository at *assets/worker-configmap.yml* contains a
configmap we can use for our EKS workers. We need to substitute our instance
role ARN into the template:

View the template:
```
cd ${HOME}/environment/howto-launch-eks-workshop/

cat assets/worker-configmap.yml
```
Lookup and store the Instance ARN:
```
export INSTANCE_ARN=$(aws cloudformation describe-stacks --stack-name "eksworkshop-cf-worker-nodes" --query "Stacks[0].Outputs[?OutputKey=='NodeInstanceRole'].OutputValue" --output text)

echo INSTANCE_ARN=$INSTANCE_ARN
```

Test modify the template to see what changes:
```
sed "s@.*rolearn.*@    - rolearn: $INSTANCE_ARN@" assets/worker-configmap.yml
```
Actually apply the configmap:
```
sed "s@.*rolearn.*@    - rolearn: $INSTANCE_ARN@" assets/worker-configmap.yml | kubectl apply -f /dev/stdin
```
