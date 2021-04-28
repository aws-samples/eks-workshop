---
title: "Installing Container Insights"
chapter: false
weight: 5
---

To complete the setup of Container Insights, you can follow the quick start instructions in this section.

From your Cloud9 Terminal you will just need to run the following command.

```bash
curl -s https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluentd-quickstart.yaml | sed "s/{{cluster_name}}/eksworkshop-eksctl/;s/{{region_name}}/${AWS_REGION}/" | kubectl apply -f -
```

The command above will:

* Create the `Namespace` amazon-cloudwatch.
* Create all the necessary security objects for both DaemonSet:
  * `SecurityAccount`.
  * `ClusterRole`.
  * `ClusterRoleBinding`.
* Deploy Cloudwatch-Agent (responsible for sending the **metrics** to CloudWatch) as a `DaemonSet`.
* Deploy fluentd (responsible for sending the **logs** to Cloudwatch) as a `DaemonSet`.
* Deploy `ConfigMap` configurations for both DaemonSets.

{{% notice info %}}
You can find the full information and manual install steps [here](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-quickstart.html).
{{% /notice %}}

You can verify all the `DaemonSets` have been deployed by running the following command.

```bash
kubectl -n amazon-cloudwatch get daemonsets
```

Output

{{< output >}}
NAME                 DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
cloudwatch-agent     3         3         3       3            3           <none>          2m43s
fluentd-cloudwatch   3         3         3       3            3           <none>          2m43s
{{< /output >}}

That's it. It's that simple to install the agent and get it up and running. You can follow the manual steps in the full documentation, but with the Quickstart the deployment of the Daemon is easy and quick!

### Now onto verifying the data is being collected!
