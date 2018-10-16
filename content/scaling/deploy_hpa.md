---
title: "Configure Horizontal Pod AutoScaler (HPA)"
date: 2018-08-07T08:30:11-07:00
weight: 10
draft: true
---

### Deploy the Metrics Server
Metrics Server is a cluster-wide aggregator of resource usage data. These metrics will drive the scaling behavior of the [deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/). We will deploy the metrics server using `Helm` configured in a previous [module](../../helm)

```
helm install stable/metrics-server \
    --name metrics-server \
    --version 2.0.2 \
    --namespace metrics
```
### Configure Security Groups
We need to enable HTTPS traffic on port 443 from the EKS Cluster control plane to the Worker Nodes. Browse to the [EC2 Security Groups](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#SecurityGroups:search=eksctl;sort=tag:Name)

![EC2 Security Groups](/images/scaling-ec2-sg.png)
You should see 2 security groups with names beginning with `eksctl-eks-workshop`. One is assigned to the Worker Node Group and one for the Control Plane

Check the box next to the Security group for the Control Plane and then click on `Actions` and `Edit outbound rules`

![Outbound Rules](/images/scaling-cp-outbound.png)

Create a new rule for HTTP (TCP/443) in the destination field, make sure `Custom` is selected. Type *eksctl* and you should be able to select the group containing *nodegroup* from the autocomplete results. Click `Save`

![Outbound HTTPS](/images/scaling-cp-https.png)

Repeat the process to create an inbound rule on the Worker Node group. Check the box next to the Security group for the Node Group and then click on `Actions` and `Edit inbound rules`

Create a new rule for HTTP (TCP/443) in the destination field, make sure `Custom` is selected. Type *eksctl* and you should be able to select the group containing *ControlPlane* from the autocomplete results. Click `Save`

### Confirm the Metrics API is available.

Return to the terminal in the Cloud9 Environment
```
kubectl get apiservice v1beta1.metrics.k8s.io -o yaml
```
If all is well, you should see a status message similar to the one below in the response
```
status:
  conditions:
  - lastTransitionTime: 2018-10-15T15:13:13Z
    message: all checks passed
    reason: Passed
    status: "True"
    type: Available
```

#### We are now ready to scale a deployed application






