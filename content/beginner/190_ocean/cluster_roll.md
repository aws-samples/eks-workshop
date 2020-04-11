---
title: "Deploy Infrastructure Changes With Ease"
date: 2019-04-09T00:00:00-03:00
weight: 17
draft: false
---

### Applying Infrastructure Configuration Changes
Ocean's Cluster Roll allows you to apply changes to instance configurations (modifying AMI, User-Data, Security-Group, Private IP, etc.) and roll your cluster in a single click. This replaces the running instances in a blue-green manner, in batches of a configurable size. 

Ocean's Cluster Roll takes into consideration the actual pods currently running in the cluster and is aware of any new workload entering the cluster. It launches compute capacity to match the workload’s requirements, and freezes any auto-scaling related activity, until the roll is completed. As a result, once the Roll is completed, no further re-adjustment via scale-up or scale-down is required. 

#### Creating A Cluster Roll
On the top right corner of your Ocean cluster's console, select “Actions” and then choose  "Cluster Roll”.
<img src="/images/ocean/actions_cluster_roll.png" alt="Actions - Cluset Roll" />

In the pop-up window, configure the batch size - a percentage of the cluster’s target capacity (the total amount of nodes in the cluster) to roll at once. This will determine the number of batches in the Roll. You can optionally add a comment, specifying why the Roll was made.

<img src="/images/ocean/cluster_roll_configuration.png" alt="Cluset Roll Configuration" width="500"/>

Finally, from the "Cluster Rolls" tab of the Ocean console you can monitor the progress of the Cluster Roll you have created, stop it, or view any previous Rolls.

<img src="/images/ocean/cluster_roll_tab.png" alt="Cluster Rolls Tab" width="700"/>