---
title: "Deploy Jenkins"
date: 2018-08-07T08:30:11-07:00
weight: 20
draft: true
---

With our Storage Class configured we then need to create our `jenkins` setup. To
do this we'll just use the `helm` cli with a couple flags.

{{% notice info %}}
In a production system you should be using a `values.yaml` file so that you can
manage the drift as you need to update releases
{{% /notice %}}

#### Install Jenkins

```
helm install stable/jenkins --set rbac.install=true --name cicd
```

The output of this command will give you some additional information such as the
`admin` password and the way to get the host name of the ELB that was
provisioned.

Let's give this some time to provision and while we do let's watch for pods
to boot.

```
kubectl get pods -w
```

You should see the pods in `init`, `pending` or `running` state.

Once this changes to `running` we can get the `load balancer` address.

```
export SERVICE_IP=$(kubectl get svc --namespace default cicd-jenkins --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
echo http://$SERVICE_IP:8080/login
```
