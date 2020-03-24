---
title: "Connect Ocean to your EKS Cluster"
date: 2019-04-09T00:00:00-03:00
weight: 11
draft: false
---

In this section we will create a new Ocean cluster, associated with your existing EKS cluster.

### Step 1: Create A New Cluster
 - To get started with the Ocean Creation Wizard, select "Cloud Clusters" from the side menu, under "Ocean", and click the "Create Cluster" button on the top right.
 - On the Use Cases page, select "Migrate Worker Nodes' Configuration" under "Join an Existing Cluster”: 
 <img src="/images/ocean/use_cases.png" alt="Use Cases" width="700"/>

### Step 2: General Settings
 - Enter a **Cluster Name** and **Identifier** and select the **Region** of your EKS cluster.
 {{% notice info %}}
 The **Cluster Identifier** for your Ocean cluster should be unique within the account, and defaults to the Ocean Cluster Name.
 {{% /notice %}}
 - Select an **EKS Auto Scaling Group** (or alternatively, an **Instance** which should be an existing worker node) to import the cluster configuration from.
 - Click on **Next**. Ocean will now import the configuration of your EKS cluster.
 <img src="/images/ocean/general_settings.png" alt="General Settings" width="700"/>
 {{% notice note %}}
 When importing a cluster, Ocean will clone your cluster and node pools configuration. New instances will then be launched and registered directly to your cluster, and will not be visible via your node pools. Your existing instances and applications will remain unchanged.
 {{% /notice %}}


### Step 3: Compute Settings
 - Confirm or change the settings imported by the Ocean Creation Wizard.
 {{% notice tip %}}
 By default, Ocean will use as wide a selction of instance types as possible, in order to ensure optimal pricing and availabilty for your worker nodes by tapping into many EC2 Spot capacity pools. If you wish, you can exclude cerain types from the pool of instances used by the cluster, by clicking on "Customize" under "Machine Types".
 {{% /notice %}}
 <img src="/images/ocean/compute_settings.png" alt="Compute Settings" width="700"/>

### Step 4: Connectivity Configuration
 - Create a **token** with the "Generate Token" link, or use an existing one.
 - Install the **Controller pod**. Learn more about the Controller Pod and Ocean’s anatomy [here](https://api.spotinst.com/ocean/concepts/ocean-cloud/introduction/#ocean-anatomy).
 - Click **Test Connectivity** to ensure the controller's functionality.
 - Once the connectivity test is successful, click **Next** to proceed to the Review screen.
 <img src="/images/ocean/connectivity.png" alt="Connectivity" width="700"/>

### Step 5: Review And Create
 - On this page you can review your configuration, and check it out in JSON or Terraform formats.
 - When you are satisfied with all settings, click **Create**.
 <img src="/images/ocean/review.png" alt="Review" width="700"/>
 
### Step 6: Migrating Existing Nodes
In order to fully migrate any existing workloads to Ocean, the original EKS Auto Scaling group/s should be gradually drained and scaled down, while replacement nodes should be launched by Ocean. In order to make this process automatic and safe, and gradually migrate all workloads while maintaining high availablity for the application, Ocean has the "Workload Migration" feature. You can read about it [here](https://api.spotinst.com/ocean/tutorials/ocean-for-aws/ocean-tutorials-ocean-for-aws-workload-migration/), or watch the video tutorial [here](https://www.youtube.com/watch?v=101Fm3lS9Ow&list=PL_PTZ5NRsI1ad3hbZBdmDZqR38GLoMJw-&index=14). 

In the interest of stability, the Workload Migration process is very gradual, and therefore takes a while (up to half an hour), even for small workloads. So for the purposes of this workshop we will assume that our workloads can tolerate a more aggesive rescheduling. Therefore, proceed with the following steps:

1. If you have installed "Cluster Autoscaler" or set up any scaling poilicies for the orginal ASG managed by your EKS cluster, go ahead and disable them. Ocean'e Autoscaler will take their place.
2. Find the ASG associated with your EKS cluster in the EC2 console, right click it and select "edit". Set the Desired Capacity, Min and Max values to 0. If you have any pods running, Ocean's autoscaler will pick them up and scale up appropriately.

<img src="/images/ocean/scale_down_asg.png" alt="ASG Edit Screen" width="700"/>

{{% notice note %}}
If you have several node groups configured, with different sets of labels, taints or launch specifications, before scaling them down make sure to configure matching "Launch Specifications" in Ocean. Have a look at the next page in the workshop to see how.
{{% /notice %}}



You’re all set! Ocean will now ensure your EKS cluster worker nodes are running on the most cost-effective, optimally sized instances possible.



