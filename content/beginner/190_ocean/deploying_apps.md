---
title: "Deploying Applications With Ocean"
date: 2019-04-09T00:00:00-03:00
weight: 13
draft: false
---

In this section we will launch a test deployment and see how Ocean handles different node configurations via the "Launch Specifications" feature.


### Easily Run Multiple Workload Types In One Cluster
The challenge of running multiple workload types (separate applications, dev/test environmets, node groups requiring a GPU AMI, etc...) on the same Kubernetes cluster is applying a unique configuration to each one of the workloads in a heterogeneous environment. When your worker nodes are managed in a standard EKS cluster, usually every workload type is managed separately in a different Auto-scaling group.

With Ocean, you can define custom "launch specifications" which allow you to configure multiple workload types on the same Ocean Cluster. As part of those launch specs, you can configure different sets of labels and taints to go along with a custom AMI, User Data script, Instance Profile, Security Group, Root Volume size and tags which will be used for the nodes that serve your matching pods. This feature ensures the ability to run any type of workload on the same Ocean Cluster.

Let's see how this works:

1. Navigate to your Ocean Cluster within the Spot.io Console, then click on the Actions menu on the top right and select "Launch Specifications".
<img src="/images/ocean/actions_launch_specs.png" alt="Actions - Launch Specs" />

2. Here you can see the "Default Launch Specification" which represents the initial configuration that the Ocean cluster was created with. To add a new configuration, click the "Add Launch Specification" button on the top right.
<img src="/images/ocean/launch_specs.png" alt="Launch Specifications" width="700"/>

3. Configure the new Launch Specification as follows:
   - Set Name to `Dev Environment`.
   - Under Node Labels, set Key to `env`, Value to `dev` and click "Add".
<img src="/images/ocean/launch_spec_1.png" alt="Launch Specification 1" width="700"/>

4. Add another Launch Specification by clicking the "Add Launch Specification" button again, and configure it as follows:
   - Set Name to `Test Environment`.
   - Under Node Labels, set Key to `env`, Value to `test` and click "Add".
<img src="/images/ocean/launch_spec_2.png" alt="Launch Specification 2" width="700"/>

5. Once you're finished (make sure you have 3 Launch Specifications), click "Update" at the bottom right of the page.

### Running a test deployment

Now we will run a deployment that will show us how Ocean scales up and automatically launches nodes from the right Launch Specification.

Below is an example yaml with 3 test desployments. 

The first test deployment, named `od` uses a selector for the `env: dev` label, and will require On-Demand instances via the `spotinst.io/node-lifecycle: od` label. You can read more about using built in labels [here](https://api.spotinst.com/ocean/concepts/ocean-cloud/spotinst-labels-taints/). The second deployment, named `dev` will also require the `env: dev` label, while the third one, named `test` should run on instances labeled `env: test`. 

```
cat <<EoF > test_deployments.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: od
spec:
  selector:
    matchLabels:
      env: dev
  replicas: 2
  template:
    metadata:
      labels:
        env: dev
    spec:
      containers:
      - name: nginx-od
        image: nginx
        resources:
          requests:
            memory: "700Mi"
            cpu: "256m"
      nodeSelector:
        spotinst.io/node-lifecycle: od
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dev
spec:
  selector:
    matchLabels:
        env: dev
  replicas: 3
  template:
    metadata:
      labels:
        env: dev
    spec:
      containers:
      - name: nginx-dev
        image: nginx
        resources:
          requests:
            memory: "800Mi"
            cpu: "800m"
          limits:
            memory: "1700Mi"
            cpu: "1700m"
      nodeSelector:
        env: dev
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test
spec:
  selector:
    matchLabels:
      env: test
  replicas: 3
  template:
    metadata:
      labels:
        env: test
    spec:
      containers:
      - name: nginx-dev
        image: nginx
        resources:
          requests:
            memory: "1700Mi"
            cpu: "500m"
          limits:
            memory: "1700Gi"
            cpu: "1700m"
      nodeSelector:
        env: test

EoF
```
Let's apply these Deployments and watch Ocean's Autoscaler in action:

```
kubectl apply -f test_deployments.yaml
```

At this point Ocean will scale up to meet the demands of the deployments. You will notice that autoscaling happens fast, and instance sizes will be optimized for efficient bin packing of resources. We expect to see at least 3 instances:

 - Two instances from the `Dev Environment` launch specification, On-Demand and Spot.
 - One Spot instance from the `Test Environment` launch specification.

You can display your nodes with:
```
 kubectl get nodes
```

The output should look like:
{{< output >}}
NAME                                           STATUS    ROLES     AGE       VERSION
ip-192-168-15-64.us-west-2.compute.internal    Ready     <none>    7m58s     v1.14.8-eks-b8860f
ip-192-168-38-150.us-west-2.compute.internal   Ready     <none>    8m24s     v1.14.8-eks-b8860f
ip-192-168-86-147.us-west-2.compute.internal   Ready     <none>    8m28s     v1.14.8-eks-b8860f
ip-192-168-92-222.us-west-2.compute.internal   Ready     <none>    8m9s      v1.14.8-eks-b8860f
{{< /output >}}

In addition, the scale up activity should be logged in the Ocean Cluster's log tab:
<img src="/images/ocean/scale_up_log.png" alt="Scale up log"/>

Clicking on "view details" will open up a window with additional information about the scaling activity:
<img src="/images/ocean/scale_up_details.png" alt="Scale up details" width="700"/>

In the next slides, we will preview some additional features and benefits of Ocean for EKS.

