---
title: "Using Helm"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

### Configure Helm access with RBAC

Helm relies on a service called **tiller** that requires special permission on the
kubernetes cluster, so we need to build a _**Service Account**_ for **tiller**
to use. We'll then apply this to the cluster.

To create a new service account manifest:
```
cat <<EoF > ~/environment/rbac.yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EoF
```

Next apply the config:
```
kubectl apply -f ~/environment/rbac.yaml
```

Then we can install **helm** using the **helm** tooling

```
helm init --service-account tiller
```

This will install **tiller** into the cluster which gives it access to manage
resources in your cluster.

### Install Demo application

Clone demo application [eksdemo-chart](https://github.com/alexei-led/eksdemo-chart) chart:

```sh
# set working directory to ~/environment
cd ~/environment

# clone this repository
git clone https://github.com/alexei-led/eksdemo-chart

# change working directory
cd eksdemo-chart
```

First time application install with release named `workshop`:

```sh
helm --debug install --name workshop eksdemo
```

### Update demo application chart

Modify `nodejs.image.repository` to `brentley/ecsdemo-nodejs-non-existing` in `values.yaml` file, setting non-existing Docker image.

Deploy the updated demo application chart:

```sh
helm upgrade workshop eksdemo
```

The `eksdemo-nodejs` Pod should fail to pull non-existing image.

Run `helm status` command to see the `ImagePullBackOff` error:

```
`helm status workshop
```

### Rollback application

Now we are going to rollback demo application to the previous working release revision.

First, list Helm release revisions:

```
helm history workshop
```

Then, rollback to the previous application revision (can rollback to any revision too):

```sh
# rollback to the 1st revision
helm rollback workshop 1
```

Validate `workshop` release status with:

```
helm status workshop
```