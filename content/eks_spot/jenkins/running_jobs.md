---
title: "Running Jenkins jobs"
date: 2018-08-07T08:30:11-07:00
weight: 70
---

We now have a dedicated Spot nodegroup with the capacity-optimized allocation strategy that should decrease the chances of Spot Instances being interrupted, and we configured Jenkins to run jobs on those EC2 Spot Instances. We also installed the Naginator plugin which will allow us to retry failed jobs.

#### Creating a Jenkins job
1. On the Jenkins dashboard, in the left pane, click **New Item**
2. Enter an item name: **Sleep-2m**, select **Freestyle project** and click **OK**
3. Scroll down to the **Build** section, and click **Add build step** -> **Execute shell**
4. For the Command, enter `sleep 2m; echo "Job finished successfully"`
5. In the Post-build Actions section, click **Add post-build action** -> **Retry build after failure**. These are the options that were added by the Naginator plugin.
6. Check the **Fixed** box and enter `20` for Fixed delay
7. Under **Maximum number of successive failed builds** enter `3`
8. Click **Save**

{{% notice note %}}
Since this workshop module focuses on resilience and cost optimization for Jenkins jobs, we are running a very simple job that will not perform any actions other than to sleep for 2 minutes and echo a message that it finished successfully to the console.
{{% /notice %}}

#### Running the Jenkins job
1\. On the project page for Sleep-2m, in the left pane, click the **Build Now** button\
2\. Browse to the Kube-ops-view tool, and check that a new pod was deployed with a name that starts with `jenkins-agent-`\

{{%expand "Show me how to get kube-ops-view url" %}}
Execute the following command on Cloud9 terminal
```
kubectl get svc kube-ops-view | tail -n 1 | awk '{ print "Kube-ops-view URL = http://"$4 }'
```
{{% /expand %}}

3\. Check the node on which the pod is running - is the nodegroup name jenkins-agents-2vcpu-8gb-spot? If so, it means that our labeling and Node Selector were configured successfully. \
4\. Run `kubectl get pods`, and find the name of the Jenkins master pod (i.e cicd-jenkins-123456789-abcde)\
5\. Run `kubectl logs -f <pod name from last step> `\
6\. Do you see log lines that show your job is being started? for example "Started provisioning Kubernetes Pod Template from kubernetes with 1 executors. Remaining excess workload: 0"\
7\. Back on the Jenkins Dashboard, In the left pane, click **Build History** and click the console icon next to the latest build. When the job finishes, you should see the following console output:\

```
Building remotely on jenkins-agent-bwtmp (cicd-jenkins-slave) in workspace /home/jenkins/agent/workspace/Sleep-2m
[Sleep-2m] $ /bin/sh -xe /tmp/jenkins365818066752916558.sh
+ sleep 2m
+ echo Job finished successfully
Job finished successfully
Finished: SUCCESS
```

#### Job failure and automatic retry
Now that we ran our job successfully on Spot Instances, let's test the failure scenario. Since we cannot simulate an EC2 Spot Interruption on instances that are running in an EC2 Auto Scaling group, we will demonstrate a similar effect by simply terminating the instance that our job/pod is running on.

1. Go back to the Sleep-2m project page in Jenkins, and click **Build Now**
2. Run `kubectl get po --selector jenkins/cicd-jenkins-slave=true -o wide` to find the Jenkins agent pod and the node on which it is running
3. Run `kubectl describe node <node name from the last command>` to find the node's EC2 Instance ID under the `alpha.eksctl.io/instance-id` label
4. Run `aws ec2 terminate-instances --instance-ids <instance ID from last command>`
5. Back in the Jenkins dashboard, under the **Build History** page, you should now see the Sleep-2m job as broken. You can click the Console button next to the failed run, to see the JNLP errors that indicate that the Jenkins agent was unable to communicate to the Master, due to the termination of the EC2 Instance.
6. Within 1-3 minutes, the EC2 Auto Scaling group will launch a new replacement instance, and once it has joined the cluster, the sleep-2m job will be retried on the new node. You should see see the sleep-2m job succeed in the Build History page or Project page.

Now that we successfully ran a job on a Spot Instance, and automatically restarted a job due to a simulated node failure, let's move to the next step in the workshop and autoscale our Jenkins nodes.
