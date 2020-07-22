---
title: "Scale the Application"
date: 2018-08-07T08:30:11-07:00
weight: 50
---

We are now ready to test the Horizontal Pod Autoscaler! As a bonus we will also see the interaction between Cluster Autoscaler and Horizontal Pod Autoscaler.

### Deploying the Stress CLI to Cloud 9

To help us stress the application we will install a python helper app. The python helper application just calls in parallel on multiple process request to the monte-carlo-pi-service. This will generate load in our pods, which will also trigger the Horizontal Pod Autoscaler action for scaling the monte-carlo-pi-service replicaset.

```
mkdir -p ~/environment/submit_mc_pi_k8s_requests/
curl -o ~/environment/submit_mc_pi_k8s_requests/submit_mc_pi_k8s_requests.py https://raw.githubusercontent.com/ruecarlo/eks-workshop-sample-api-service-go/master/stress_test_script/submit_mc_pi_k8s_requests.py
chmod +x ~/environment/submit_mc_pi_k8s_requests/submit_mc_pi_k8s_requests.py
curl -o ~/environment/submit_mc_pi_k8s_requests/requirements.txt https://raw.githubusercontent.com/ruecarlo/eks-workshop-sample-api-service-go/master/stress_test_script/requirements.txt
sudo python3 -m pip install -r ~/environment/submit_mc_pi_k8s_requests/requirements.txt
URL=$(kubectl get svc monte-carlo-pi-service | tail -n 1 | awk '{ print $4 }')
~/environment/submit_mc_pi_k8s_requests/submit_mc_pi_k8s_requests.py -p 1 -r 1 -i 1 -u "http://${URL}"
```

The output of this command should show something like:
```
Total processes: 1
Len of queue_of_urls: 1
content of queue_of_urls: ab79391edde2d11e9874706fbc6bc60f-1090433505.eu-west-1.elb.amazonaws.com/?iterations=1
100%|█████████████████████████████████████████████████████████████████████████████████████████████████████████| 1/1 [00:00<00:00, 8905.10it/s]
```

### Scaling our Application and Cluster

{{% notice note %}}
Before starting the stress test, predict what would be the expected outcome. Use **kube-ops-view** to verify that the changes you were expecting to happen, do in fact happen over time. 
{{% /notice %}}
{{%expand "Show me how to get kube-ops-view url" %}}
Execute the following command on Cloud9 terminal
```
kubectl get svc kube-ops-view | tail -n 1 | awk '{ print "Kube-ops-view URL = http://"$4 }'
```
{{% /expand %}}

Run the stress test ! This time around we will run 2000 requests each expected to take ~1.3sec or so.
```
time ~/environment/submit_mc_pi_k8s_requests/submit_mc_pi_k8s_requests.py -p 100 -r 30 -i 30000000 -u "http://${URL}"
```

### Challenge 

While the application is running, can you answer the following questions ?

 * How can we track the status of the Horizontal Pod Autoscheduler rule that was set up in the previous section ?

 * How about the nodes or pods  ? 

{{% notice tip %}}
Feel free to use [kubectl cheat sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/) to find out your responses. You can open multiple tabs on Cloud9.
{{% /notice %}}



 {{% expand "Show answers" %}}
 To display the progress of the rule was setup in Horizontal Pod Autoscaler we can run:
```
kubectl get hpa -w
```
This should show the current progress and target pods, and refresh a new line every few seconds.
```
:~/environment $ kubectl get hpa -w
NAME                     REFERENCE                           TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
monte-carlo-pi-service   Deployment/monte-carlo-pi-service   0%/50%      4         100       4        33m
monte-carlo-pi-service   Deployment/monte-carlo-pi-service   0%/50%      4         100       4        34m
monte-carlo-pi-service   Deployment/monte-carlo-pi-service   100%/50%    4         100       4        35m
monte-carlo-pi-service   Deployment/monte-carlo-pi-service   100%/50%    4         100       8        35m
monte-carlo-pi-service   Deployment/monte-carlo-pi-service   94%/50%     4         100       8        36m
monte-carlo-pi-service   Deployment/monte-carlo-pi-service   94%/50%     4         100      16        36m
monte-carlo-pi-service   Deployment/monte-carlo-pi-service   92%/50%     4         100      16        37m
monte-carlo-pi-service   Deployment/monte-carlo-pi-service   92%/50%     4         100      19        37m
monte-carlo-pi-service   Deployment/monte-carlo-pi-service   94%/50%     4         100      19        38m
monte-carlo-pi-service   Deployment/monte-carlo-pi-service   85%/50%     4         100      19        39m
monte-carlo-pi-service   Deployment/monte-carlo-pi-service   85%/50%     4         100      29        39m
monte-carlo-pi-service   Deployment/monte-carlo-pi-service   54%/50%     4         100      29        40m
monte-carlo-pi-service   Deployment/monte-carlo-pi-service   0%/50%      4         100      29        41m
monte-carlo-pi-service   Deployment/monte-carlo-pi-service   0%/50%      4         100      29        45m
monte-carlo-pi-service   Deployment/monte-carlo-pi-service   0%/50%      4         100      12        46m
monte-carlo-pi-service   Deployment/monte-carlo-pi-service   0%/50%      4         100      12        47m
monte-carlo-pi-service   Deployment/monte-carlo-pi-service   0%/50%      4         100       4        48m
```


To display the node or pod you can use
```
kubectl top nodes
```

or 
```
kubectl top pods
```
 {{% /expand %}} 


### Optional Exercises

{{% notice warning %}}
Some of this exercises will take time for Horizontal Pod Autoscaler and Cluster Autoscaler to scale up and down. If you are running this
workshop at a AWS event or with limited time, we recommend to come back to this section once you have completed the workshop, and before getting into the **cleanup** section.
{{% /notice %}}

 * While kube-ops-view is great to get an intuition of how the cluster status is at a specific point in time, it is not great to see changes over time. Run through the **[MONITORING USING PROMETHEUS AND GRAFANA](https://eksworkshop.com/intermediate/240_monitoring/)** module in the https://eksworkshop.com. Install grafana public dashboard [#6417](https://grafana.com/grafana/dashboards/6417). Re-run the same scaling exercise and see how available resources and requested resources evolve.

 * Check the `~/environment/submit_mc_pi_k8s_requests/submit_mc_pi_k8s_requests.py`. Comment line 18 and uncomment line 19. This will display requests timeouts. Re-run the test starting from the original setup and see what's the impact and how many timeouts we had. 

 * Scaling operations can be a bit slow; Could you explain why those operations are slow ? ([hint](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#how-fast-is-hpa-when-combined-with-ca)) As we have seen on the completion of the previous exercise, this can also cause requests to timeout. Could you think of any technique or configuration that would help you palliate this scenario?

 * One technique to manage a "buffer of capacity" to avoid timeouts, is to **overprovision** the cluster. Read about how to [configure overprovisioning with Cluster Autoscaler](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#how-can-i-configure-overprovisioning-with-cluster-autoscaler). 

 * On the topic of monitoring and reporting: Take a look at the instructions on how to setup [CloudWatch Container Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/deploy-container-insights-EKS.html) on EKS. All the spot nodegroups we have created in the cluster already do have already a CloudWatch write policy attached: Could you explain how and when this was done ?. Follow the documentation and apply the cloudwatch policy to the initial on-demand nodegroup that we created.  Inspect the metrics that [CloudWatch Container Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-metrics-EKS.html) provide in the dashboard and inspect the monte-carlo-pi-service logs.
