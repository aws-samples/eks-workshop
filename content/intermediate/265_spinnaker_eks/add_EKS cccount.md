---
title: "Add EKS Account"
weight: 40
draft: false
---

At a high level, Spinnaker operates in the following way when deploying to Kubernetes:

- Spinnaker is configured with one or more “Cloud Provider” Kubernetes accounts (which you can think of as deployment targets)
- For each Kubernetes account, Spinnaker is provided a kubeconfig to connect to that Kubernetes cluster
- The kubeconfig should have the following contents:
  - A Kubernetes kubeconfig cluster
  - A Kubernetes kubeconfig user
  - A Kubernetes kubeconfig context
  - Metadata such as which context to use by default
- Each Kubernetes account is configured in the SpinnakerService manifest under spec.spinnakerConfig.config.providers.kubernetes.accounts key. Each entity has these (and other) fields:
  - name: A Spinnaker-internal name
  - kubeconfigFile: A file path referencing the contents of the kubeconfig file for connecting to the target cluster.
  - onlySpinnakerManaged: When true, Spinnaker only caches and displays applications that have been created by Spinnaker. 
  - namespaces: An array of namespaces that Spinnaker will be allowed to deploy to. If this is left blank, Spinnaker will be allowed to deploy to all namespaces
  - omitNamespaces: If namespaces is left blank, you can blacklist specific namespaces to indicate to Spinnaker that it should not deploy to those namespaces
- If the kubeconfig is properly referenced and available, Operator will take care of the following:
  - Creating a Kubernetes secret containing your kubeconfig in the namespace where Spinnaker lives
  - Dynamically generating a clouddriver.yml file that properly references the kubeconfig from where it is mounted within the Clouddriver container
  - Creating/Updating the Kubernetes Deployment (spin-clouddriver) which runs Clouddriver so that it is aware of the secret and properly mounts it in the Clouddriver pod

Now, lets add a Kubernetes/EKS Account Deployment Target in Spinnaker.

#### Download the latest spinnaker-tools release

This tool helps to create the ServiceAccount, ClusterRoleBinding, kubeconfig for the service account for the EKS/Kubernetes account
```
cd ~/environment
git clone https://github.com/armory/spinnaker-tools.git
cd spinnaker-tools
go mod download all
go build
```

{{< output >}}
Cloning into 'spinnaker-tools'...
remote: Enumerating objects: 278, done.
remote: Counting objects: 100% (6/6), done.
remote: Compressing objects: 100% (6/6), done.
remote: Total 278 (delta 0), reused 4 (delta 0), pack-reused 272
Receiving objects: 100% (278/278), 84.72 KiB | 4.71 MiB/s, done.
Resolving deltas: 100% (124/124), done.
{{< /output >}}

#### Setup environment variables

  ```sh
  export CONTEXT=$(kubectl config current-context)
  export SOURCE_KUBECONFIG=${HOME}/.kube/config
  export SPINNAKER_NAMESPACE="spinnaker"
  export SPINNAKER_SERVICE_ACCOUNT_NAME="spinnaker-ws-sa"
  export DEST_KUBECONFIG=${HOME}/Kubeconfig-ws-sa

  echo $CONTEXT
  echo $SOURCE_KUBECONFIG
  echo $SPINNAKER_NAMESPACE
  echo $SPINNAKER_SERVICE_ACCOUNT_NAME
  echo $DEST_KUBECONFIG
  ```

{{% notice info %}}
If you do not see output from the above command for all the above Environment Variables, do not proceed to next step
{{% /notice %}}


#### Create the service account

Create the kubernetes service account with namespace-specific permissions

```
./spinnaker-tools create-service-account   --kubeconfig ${SOURCE_KUBECONFIG}   --context ${CONTEXT}   --output ${DEST_KUBECONFIG}   --namespace ${SPINNAKER_NAMESPACE}   --service-account-name ${SPINNAKER_SERVICE_ACCOUNT_NAME}
```
{{< output >}}
Cloning into 'spinnaker-tools'...
remote: Enumerating objects: 278, done.
remote: Counting objects: 100% (6/6), done.
remote: Compressing objects: 100% (6/6), done.
remote: Total 278 (delta 0), reused 4 (delta 0), pack-reused 272
Receiving objects: 100% (278/278), 84.72 KiB | 4.71 MiB/s, done.
Resolving deltas: 100% (124/124), done.

Getting namespaces ...
Creating service account spinnaker-ws-sa ...
Created ServiceAccount spinnaker-ws-sa in namespace spinnaker
Adding cluster-admin binding to service account spinnaker-ws-sa ...
Created ClusterRoleBinding spinnaker-spinnaker-ws-sa-admin in namespace spinnaker
Getting token for service account ... 
Cloning kubeconfig ... 
Renaming context in kubeconfig ... 
Switching context in kubeconfig ... 
Creating token user in kubeconfig ... 
Updating context to use token user in kubeconfig ... 
Updating context with namespace in kubeconfig ... 
Minifying kubeconfig ... 
Deleting temp kubeconfig ... 
Created kubeconfig file at /home/ec2-user/Kubeconfig-ws-sa
{{< /output >}}


#### Configure EKS Account

Open the `SpinnakerService` manifest located at deploy/spinnaker/basic/spinnakerservice.yml, then add the below section under `spec.spinnakerConfig.profiles`.

  {{< output >}}
        providers:
            dockerRegistry:
              enabled: true
            kubernetes:
              enabled: true
              accounts:
              - name: spinnaker-workshop
                requiredGroupMembership: []
                providerVersion: V2
                permissions:
                dockerRegistries:
                  - accountName: my-ecr-registry
                configureImagePullSecrets: true
                cacheThreads: 1
                namespaces: [spinnaker,detail]
                omitNamespaces: []
                kinds: []
                omitKinds: []
                customResources: []
                cachingPolicies: []
                oAuthScopes: []
                onlySpinnakerManaged: false
                kubeconfigFile: kubeconfig-sp  # File name must match "files" key
              primaryAccount: spinnaker-workshop  # Change to a desired account from the accounts array
   {{< /output >}}


Open the `SpinnakerService` manifest located at deploy/spinnaker/basic/spinnakerservice.yml, then add the below section under `spec.spinnakerConfig`. Replace the `<FILE CONTENTS HERE>` in below section with kubeconfig file content created from [previous step](/265_spinnaker_eks/add_eks-cccount/#create-the-service-account) from the location ${HOME}/Kubeconfig-ws-sa. 

  {{< output >}}
    files: 
        kubeconfig-sp: |
           <FILE CONTENTS HERE> # Content from kubeconfig created by Spinnaker Tool
   {{< /output >}}

Congratulations! You are done with the Spinnaker configuration for all the Spinnaker services! Lets install Spinnaker now.