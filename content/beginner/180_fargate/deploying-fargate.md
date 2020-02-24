---
title: "Deploying Pods to Fargate"
date: 2019-04-09T00:00:00-03:00
weight: 12
draft: false
---

#### Deploying Pods to Fargate 
Next, you will deploy the NGINX pods into Fargate by executing the following commands.
```
mkdir -p ~/environment/fargate
cd ~/environment/fargate
wget https://eksworkshop.com/beginner/180_fargate/fargate.files/nginx-deployment.yaml
```

```
kubectl apply -f nginx-deployment.yaml
```
Check the status of the pods by running the next command and you should see the following output

```
kubectl get pods -n fargate
```

Output: 
{{< output >}}
NAME                         READY   STATUS    RESTARTS   AGE
nginx-app-57d5474b4b-ccs9x   1/1     Running   0          61s
nginx-app-57d5474b4b-khzpw   1/1     Running   0          61s
{{< /output >}}

The STATUS of the pods will change from <b>Pending</b> to <b>ContainerCreating</b> to ultimately <b>Running</b>.

Next, run the following command to list all the nodes in the EKS cluster and you should see output as follows:

```
kubectl get nodes
```

Output: 
{{< output >}}
fargate-ip-192-168-138-130.ec2.internal   Ready    <none>   100s   v1.14.8-eks
fargate-ip-192-168-169-166.ec2.internal   Ready    <none>   99s    v1.14.8-eks
ip-192-168-36-165.ec2.internal            Ready    <none>   8d     v1.14.7-eks-1861c5
ip-192-168-5-177.ec2.internal             Ready    <none>   27h    v1.14.7-eks-1861c5
ip-192-168-91-68.ec2.internal             Ready    <none>   27h    v1.14.7-eks-1861c5
{{< /output >}}

If your cluster has any worker nodes, they will be listed with a name starting wit the <b>ip-</b> prefix. In addition to the worker nodes, if any, there will now be two additional “fargate” nodes listed. These are merely kubelets from the microVMs in which your NGINX pods are running under Fargate, posing as nodes to the EKS Control Plane. This is how the EKS Control Plane stays aware of the Fargate infrastructure under which the pods it orchestrates are running. There will be a “fargate” node added to the cluster for each pod deployed on Fargate.