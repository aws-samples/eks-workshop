---
title: "Configure Cluster Autoscaler (CA)"
date: 2018-08-07T08:30:11-07:00
weight: 30
---
Cluster Autoscaler for AWS provides integration with Auto Scaling groups. It enables users to choose from four different options of deployment:



* One Auto Scaling group
* **Multiple Auto Scaling groups** - This is what we will use
* Auto-Discovery
* Master Node setup

### Configure the Cluster Autoscaler (CA)
We have provided a manifest file to deploy the CA. Copy the commands below into your Cloud9 Terminal.

```
mkdir ~/environment/cluster-autoscaler
cd ~/environment/cluster-autoscaler
wget https://eksworkshop.com/spot/scaling/deploy_ca.files/cluster_autoscaler.yml
```

### Configure the ASG
We will need to provide the name of the Auto Scaling Groups (ASGs) that we want CA to manipulate. 

Collect the name of each of the **three** ASGs containing your worker nodes. Record the name somewhere. We will us this later in the manifest file.

  You can find them in the console by following this [**link**](https://console.aws.amazon.com/ec2/autoscaling/home?#AutoScalingGroups)

  ![ASG](/images/scaling-asg.png)

Check the box beside each ASG and click `Actions` and `Edit`

Change the following settings:

* Min: **1**
* Desired: **1**
* Max: **8**

![ASG Config](/images/scaling-asg-config.png)

Click `Save`

### Configure the Cluster Autoscaler

Using the file browser on the left, open cluster-autoscaler.yml

Search for `command:` and within this block, replace the placeholder text `<AUTOSCALING GROUP NAME>` with one of the ASG names that you copied in the previous step. Also, update `<AWS_REGION>` value to reflect the region you are using and **Save** the file.

```
command:
  - ./cluster-autoscaler
  - --v=4
  - --stderrthreshold=info
  - --cloud-provider=aws
  - --skip-nodes-with-local-storage=false
  - --expander=most-pods
  - --nodes=2:8:<ON DEMAND AUTOSCALING GROUP NAME>
  - --nodes=2:8:<SPOT 1 AUTOSCALING GROUP NAME>
  - --nodes=2:8:<SPOT 2 AUTOSCALING GROUP NAME>
env:
  - name: AWS_REGION
    value: <AWS_REGION>
```
This command contains all of the configuration for the Cluster Autoscaler. The primary config is the `--nodes` flag. This specifies the minimum nodes **(2)**, max nodes **(8)** and **ASG Name**.

Although Cluster Autoscaler is the de facto standard for automatic scaling in K8s, it is not part of the main release. We deploy it like any other pod in the kube-system namespace, similar to other management pods.

### Deploy the Cluster Autoscaler

```
kubectl apply -f ~/environment/cluster-autoscaler/cluster_autoscaler.yml
```

Watch the logs
```
kubectl logs -f deployment/cluster-autoscaler -n kube-system
```

#### We are now ready to scale our cluster

{{%attachments title="Related files" pattern=".yml"/%}}
