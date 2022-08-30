---
title: "Install Karpenter"
weight: 20
draft: false
---

In this section we will install Karpenter and learn how to configure a default [Provisioner CRD](https://karpenter.sh/docs/provisioner-crd/) to set the configuration. Karpenter is installed in clusters with a [helm](https://helm.sh/) chart. Karpenter follows best practices for kubernetes controllers for its configuration. Karpenter uses [Custom Resource Definition(CRD)](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) to declare its configuration. Custom Resources are extensions of the Kubernetes API. One of the premises of Kubernetes is the [declarative aspect of its APIs](https://kubernetes.io/docs/concepts/overview/kubernetes-api/). Karpenter simplifies its configuration by adhering to that principle.

## Install Karpenter Helm Chart

Before the chart can be installed the repo needs to be added to Helm, run the following commands to add the repo.
```bash
helm repo add karpenter https://charts.karpenter.sh/
helm repo update
```

Install the chart passing in the cluster details and the Karpenter role ARN.

```bash
helm upgrade --install --namespace karpenter --create-namespace \
  karpenter karpenter/karpenter \
  --version ${KARPENTER_VERSION} \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=${KARPENTER_IAM_ROLE_ARN} \
  --set clusterName=${CLUSTER_NAME} \
  --set clusterEndpoint=$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.endpoint" --output json) \
  --set defaultProvisioner.create=false \
  --set aws.defaultInstanceProfile=KarpenterNodeInstanceProfile-${CLUSTER_NAME} \
  --wait # for the defaulting webhook to install before creating a Provisioner
```

The command above:
* uses the **CLUSTER_NAME** so that Karpenter controller can contact the Cluster API Server.

* Karpenter configuration is provided through a Custom Resource Definition. We will be learning about providers in the next section, the `--wait` notifies the webhook controller to wait until the Provisioner CRD has been deployed.

To check Karpenter is running you can check the Pods, Deployment and Service are Running.
```bash
kubectl get all -n karpenter
```

To check the deployment. There should be one deployment `karpenter`
```bash
kubectl get deployment -n karpenter
```

To check running pods run the command below. There should be at least two pods, each having two containers `controller` and `webhook`
```bash
kubectl get pods --namespace karpenter
```

To check containers `controller` and `webhook`, describe pod using following command
```bash
kubectl get pod -n karpenter --no-headers | awk '{print $1}' | head -n 1 | xargs kubectl describe pod -n karpenter
```


{{% notice note %}}
You can increase the number of Karpenter replicas in the deployment for resilience. Karpenter will elect a leader controller that is in charge of running operations.
{{% /notice %}}


