---
title: "Install Karpenter"
weight: 20
draft: false
---

In this section we will install Karpenter and learn how to configure a default [Provisioner CRD](https://karpenter.sh/docs/provisioner-crd/) to set the configuration. Karpenter is installed in clusters with a [helm](https://helm.sh/) chart. Karpenter follows best practices for kubernetes controllers for its configuration. Karpenter uses [Custom Resource Definition(CRD)](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) to declare its configuration. Custom Resources are extensions of the Kubernetes API. One of the premises of Kubernetes is the [declarative aspect of its APIs](https://kubernetes.io/docs/concepts/overview/kubernetes-api/). Karpenter similifies its configuration by adhering to that principle.

## Install Karpenter Helm Chart

We will use helm to deploy Karpenter to the cluster. 

{{% notice info %}}
We will install Karpenter v0.5.1 which is compatible with Kubernetes 1.21 used in this workshop.
{{% /notice %}}

```bash
helm repo add karpenter https://charts.karpenter.sh
helm repo update
helm upgrade --install karpenter karpenter/karpenter --namespace karpenter \
  --create-namespace --set serviceAccount.create=false --version 0.5.1 \
  --set controller.clusterName=${CLUSTER_NAME} \
  --set controller.clusterEndpoint=$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.endpoint" --output json) \
  --set defaultProvisioner.create=false \
  --wait # for the defaulting webhook to install before creating a Provisioner
```

The command above:
* uses the  service account that we created in the previous step, hence it sets the `--set serviceAccount.create=false`

* uses the both the **CLUSTER_NAME** and the **CLUSTER_ENDPOINT** so that Karpenter controller can contact the Cluster API Server.

* uses the `--set defaultProvisioner.create=false`. We will set a default Provisioner configuration in the next section. This will help us understand Karpenter Provisioners.

* Karpenter configuration is provided through a Custom Resource Definition. We will be learning about providers in the next section, the `--wait` notifies the webhook controller to wait until the Provisioner CRD has been deployed.

To check Karpenter is running you can check the Pods, Deployment and Service are Running.

To check running pods run the command below. There should be at least two pods `karpenter-controller` and `karpenter-webhook`
```bash
kubectl get pods --namespace karpenter
```

To check the deployment. Like with the pods, there should be two deployments  `karpenter-controller` and `karpenter-webhook`
```bash
kubectl get deployment -n karpenter
```

{{% notice note %}}
You can increase the number of Karpenter replicas in the deployment for resilience. Karpenter will elect a leader controller that is in charge of running operations.
{{% /notice %}}


