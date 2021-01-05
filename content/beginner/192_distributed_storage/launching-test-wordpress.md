---
title: "Creating a simple, highly available Wordpress deployment"
date: 2020-11-03T00:00:00-03:00
weight: 10
draft: false
---
#### Deploy the Wordpress deployment

We will use the example wordpress deployment from our cloned repo. Simply execute: 

```
kubectl apply -f ~/environment/rook/cluster/examples/kubernetes/wordpress.yaml
kubectl apply -f ~/environment/rook/cluster/examples/kubernetes/mysql.yaml
```

If the commands were executed successfully, we can check the deployed resources using something like: 

```
timeout 20 watch -n 1 kubectl get deploy
```

using timeout and watch we do not need to type commands twice if we're just want to wait for the finish of the deployment. The output when it's done looks similar to: 

{{< output >}}
Volumes:
Every 1.0s: kubectl get deploy                                                                                                                    Tue Jan  5 12:32:09 2021

NAME              READY   UP-TO-DATE   AVAILABLE   AGE
wordpress         1/1     1            1           48s
wordpress-mysql   1/1     1            1           46s
{{< /output >}}

The deployment will also deploy an service and an Elastic Load Balancer to expose our wordpress to the public internet. 
If the inital deployment went through successful, we can evaluate the Endpoint and DNS Name to access our wordpress using: 

```
kubectl get svc
```

Note down the EXTERNAL-IP. We'll use it for the next steps. 

{{< output >}}
NAME              TYPE           CLUSTER-IP      EXTERNAL-IP                                                               PORT(S)        AGE
kubernetes        ClusterIP      10.100.0.1      <none>                                                                    443/TCP        100m
wordpress         LoadBalancer   10.100.241.71   XXXXX-XXXXX.us-west-2.elb.amazonaws.com   80:31684/TCP   3m35s
wordpress-mysql   ClusterIP      None            <none>                                                                    3306/TCP       3m33s
{{< /output >}}

#### Setup Wordpress and produce content

Next we'll browse to the Wordpress instance using our browser of choise and setup our wordpress. Use the address we noted down at the step before. 

![wordpress](/images/distributedstoragewithrook/wordpress_screen1.png)

Walk through the wordpress install wizard. And log into your freshly configured wordpress. You'll end up at the default dashboard

![wordpress](/images/distributedstoragewithrook/wordpress_screen2.png)

Play around, upload pictures and create some test content like blog posts. If you need help here are some neat [tutorials how to get started](https://wordpress.com/learn/get-published/) with wordpress contend publishing. 

When played enough. let's test out the high availablity of our deployment.

#### Drain the worker node your wordpress is running on to force relocating into other node/AZ

First we'll evaluate on which worker node the wordpress pod is running

```
kubectl get po -o wide -l app=wordpress
``` 

The command will show us the pods related to our wordpress deployment as well as the nodes they're running on. 

{{< output >}}
NAME                              READY   STATUS    RESTARTS   AGE   IP              NODE                                          NOMINATED NODE   READINESS GATES
wordpress-5b886cf59b-mrd72        1/1     Running   0          28m   192.168.4.25    ip-192-168-6-134.us-west-2.compute.internal   <none>           <none>
wordpress-mysql-b9ddd6d4c-77k2r   1/1     Running   0          28m   192.168.1.131   ip-192-168-6-134.us-west-2.compute.internal   <none>           <none>
{{< /output >}}

In this example all pods are running on node *ip-192-168-6-134.us-west-2.compute.internal*

So let's simulate the node going down, e.g. for maintenance. Let's drain it to enforce the pods being relocated: 

```
kubectl drain ip-192-168-6-134.us-west-2.compute.internal
```

*Hint: Be sure to alter the node name to the one you found in your personal output!*

#### Challenge:
**How can we check if the pods where up and running on a new worker node?**

{{%expand "Expand here to see the solution" %}}
```
kubectl get po -o wide -l app=wordpress
```

{{< output >}}
NAME                              READY   STATUS    RESTARTS   AGE    IP               NODE                                           NOMINATED NODE   READINESS GATES
wordpress-5b886cf59b-xd5ff        1/1     Running   0          3m5s   192.168.46.145   ip-192-168-43-123.us-west-2.compute.internal   <none>           <none>
wordpress-mysql-b9ddd6d4c-v4dpk   1/1     Running   0          3m5s   192.168.46.84    ip-192-168-43-123.us-west-2.compute.internal   <none>           <none>
{{< /output >}}

You will recordnized the Node name and ip where the pods are now running at changed to another  worker node. 
{{% /expand %}}

#### We did move to a node, where is my content? 

After switching to a new node running at another Availability Zone we need to check if our content is still there. 
Switch to our Wordpress dashboard and check the content we produced. 

Pfew. Still everything available and up and running without any further action to be taken. 

**Congratz! We've sucessfully setup a simple high available wordpress deployment**