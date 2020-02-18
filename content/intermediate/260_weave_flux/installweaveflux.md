---
title: "Install Weave Flux"
date: 2018-10-087T08:30:11-07:00
weight: 15
draft: false
---

Now we will use Helm to install Weave Flux into our cluster and enable it to interact with our Kubernetes configuration GitHub repo.  

First, install the Flux Custom Resource Definition:

```
kubectl apply -f https://raw.githubusercontent.com/fluxcd/flux/helm-0.10.1/deploy-helm/flux-helm-release-crd.yaml
```

> In the following steps, your Git user name will be required. Without this information, the resulting pipeline will not function as expected. Set this as an environment variable to reuse in the next commands:

```bash
YOURUSER=yourgitusername
```

Next, add the Flux chart repository to Helm and install Flux.  

{{% notice info %}}
Update the Git URL below to match your user name and Kubernetes configuration manifest repository.
{{% /notice %}}

```
helm repo add fluxcd https://charts.fluxcd.io

helm upgrade -i flux \
--set helmOperator.create=true \
--set helmOperator.createCRD=false \
--set git.url=git@github.com:${YOURUSER}/k8s-config \
--namespace flux \
fluxcd/flux
```

Watch the install and confirm everything starts.  There should be 3 pods.  
```
kubectl get pods -n flux
```

Install fluxctl in order to get the SSH key to allow GitHub write access.  This allows Flux to keep the configuration in GitHub in sync with the configuration deployed in the cluster.  

```
sudo wget -O /usr/local/bin/fluxctl https://github.com/fluxcd/flux/releases/download/1.14.1/fluxctl_linux_amd64
sudo chmod 755 /usr/local/bin/fluxctl

fluxctl version
fluxctl identity --k8s-fwd-ns flux
```

Copy the provided key and add that as a deploy key in the GitHub repository.  

* In GitHub, select your k8s-config GitHub repo.  Go to **Settings** and click **Deploy Keys**.  Alternatively, you can go by direct URL by replacing your user name in this URL: **github.com/YOURUSER/k8s-config/settings/keys**.  
* Click on **Add Deploy Key**
 * Name: **Flux Deploy Key**
 * Paste the key output from fluxctl
 * Click **Allow Write Access**.  This allows Flux to keep the repo in sync with the real state of the cluster
 * Click **Add Key**

Now Flux is configured and should be ready to pull configuration.  
