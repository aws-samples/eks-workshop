---
title: "Configure Horizontal Pod AutoScaler (HPA)"
date: 2018-08-07T08:30:11-07:00
weight: 10
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
We need to make sure Outbound port 443 from EKS Cluster Control Plane is open to Worker nodes Security Group (SG). Similarly, there needs to be an Inbound rule on Worker nodes SG being open from Control Plane SG. You can go their directly using [EC2 Security Groups link](https://console.aws.amazon.com/ec2/v2/home?#SecurityGroups:tag:Name=eksworkshop*;sort=groupId)

![EC2 Security Groups](/images/scaling-ec2-sg.png)
You should see 2 security groups with names beginning with `eksctl-eksworkshop`. One is for the Control Plane (has ControlPlaneSecurityGroup in the name) and the other is for Worker Nodes. If you don't see any security groups, make sure you are in the right region

Check the box next to the Security group for the Control Plane and check its Outbound rules.

![Outbound HTTPS](/images/scaling-cp-https.png)

If you don't have port 443 Outbound rule to Worker nodes, create a new rule with fields HTTPS (TCP/443) and enter `Custom` in the destination field. Type *eksctl* and select the group containing *nodegroup* from the autocomplete results. Click `Save`

Repeat the process to create an inbound rule on the Worker Node group. Check the box next to the Security group for the Node Group and then click on `Actions` and `Edit inbound rules`

Create a new rule with fields HTTPS (TCP/443) and enter `Custom` in the destination field. Type *eksctl* and select the group containing *ControlPlane* from the autocomplete results. Click `Save`

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
