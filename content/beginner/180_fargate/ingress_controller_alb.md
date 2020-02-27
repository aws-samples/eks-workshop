---
title: "Deploying ALB Ingress Controller"
date: 2019-04-09T00:00:00-03:00
weight: 14
draft: false
---

### ALB Ingress Controller
Download the deployment manifest for AWS ALB Ingress controller into a local YAML file.
```
cd ~/environment/fargate
wget https://eksworkshop.com/beginner/180_fargate/fargate.files/alb-ingress-controller.yaml
```

Edit the file <b>alb-ingress-controller.yaml</b>, replacing the placeholder variables <b>YOUR_VPC_ID</b> and <b>YOUR_AWS_REGION</b> with values pertaining to the VPC ID and AWS Region of your environment.

Output
{{< output >}}
containers:
- name: alb-ingress-controller
  image: docker.io/amazon/aws-alb-ingress-controller:v1.1.4
  args:
  - --ingress-class=alb
  - --cluster-name=eksworkshop-eksctl
  - --aws-vpc-id=YOUR_VPC_ID
  - --aws-region=YOUR_AWS_REGION
{{< /output >}}

Make sure that the cluster name in <b>alb-ingress-controller.yaml</b> matches that of the output when you execute the following command.
```
aws eks list-clusters
```
Output:
{{< output >}}
{
    "clusters": [
        "eksworkshop-eksctl"
    ]
}
{{< /output >}}


Save your changes and run the following command to deploy the ingress controller.
```
kubectl apply -f alb-ingress-controller.yaml
```

Execute the following command and you will see the list of all pods running under Fargate
```
kubectl get pods -n fargate
```

Output:
{{< output >}}
NAME                                      READY   STATUS    RESTARTS   AGE
alb-ingress-controller-68896c8c99-pdmtg   1/1     Running   0          5s
nginx-app-57d5474b4b-ccs9x                1/1     Running   0          52m
nginx-app-57d5474b4b-khzpw                1/1     Running   0          52m
{{< /output >}}

