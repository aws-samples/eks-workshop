---
title: "Test EKS access"
date: 2020-04-05T18:00:00-00:00
draft: false
weight: 40
---

## Automate assumerole with aws cli

It is possible to automate the retrieval of temporary credentials for the assumed role by configuring the aws cli using `.aws/config`and `.aws/credentials` files.
Examples we will define 3 profile:

#### add in `~/.aws/config`:
```
cat << EoF >> ~/.aws/config
[profile admin]
role_arn=arn:aws:iam::${ACCOUNT_ID}:role/k8sAdmin
source_profile=eksAdmin

[profile dev]
role_arn=arn:aws:iam::${ACCOUNT_ID}:role/k8sDev
source_profile=eksDev

[profile integ]
role_arn=arn:aws:iam::${ACCOUNT_ID}:role/k8sInteg
source_profile=eksInteg

EoF
```

#### create `~/.aws/credentials`:
```
cat << EoF > ~/.aws/credentials

[eksAdmin]
aws_access_key_id=$(jq -r .AccessKey.AccessKeyId /tmp/PaulAdmin.json)
aws_secret_access_key=$(jq -r .AccessKey.SecretAccessKey /tmp/PaulAdmin.json)

[eksDev]
aws_access_key_id=$(jq -r .AccessKey.AccessKeyId /tmp/JeanDev.json)
aws_secret_access_key=$(jq -r .AccessKey.SecretAccessKey /tmp/JeanDev.json)

[eksInteg]
aws_access_key_id=$(jq -r .AccessKey.AccessKeyId /tmp/PierreInteg.json)
aws_secret_access_key=$(jq -r .AccessKey.SecretAccessKey /tmp/PierreInteg.json)

EoF
```


#### Test this with dev profile:

```
aws sts get-caller-identity --profile dev
```

{{<output>}}
{
    "UserId": "AROAUD5VMKW75WJEHFU4X:botocore-session-1581687024",
    "Account": "xxxxxxxxxx",
    "Arn": "arn:aws:sts::xxxxxxxxxx:assumed-role/k8sDev/botocore-session-1581687024"
}
{{</output>}}

> the assumed-role is k8sDev, so we achieved our goal

When specifying the **--profile dev** parameter we automatically ask for temporary credentials for the role k8sDev
You can test this with **integ** and **admin** also.
 
<details>
  <summary>with admin:</summary>
  
```
aws sts get-caller-identity --profile admin
{
    "UserId": "AROAUD5VMKW77KXQAL7ZX:botocore-session-1582022121",
    "Account": "xxxxxxxxxx",
    "Arn": "arn:aws:sts::xxxxxxxxxx:assumed-role/k8sAdmin/botocore-session-1582022121"
}
```

> When specifying the **--profile admin** parameter we automatically ask for temporary credentials for the role k8sAdmin
</details>

## Using AWS profiles with Kubectl config file

It is also possible to specify the AWS_PROFILE to uses with the aws-iam-authenticator in the `.kube/config` file, so that it will uses the appropriate profile.


### with dev profile 

Create new KUBECONFIG file to test this:

```
export KUBECONFIG=/tmp/kubeconfig-dev && eksctl utils write-kubeconfig eksworkshop-eksctl
cat $KUBECONFIG | awk "/args:/{print;print \"      - --profile\n      - dev\";next}1" | sed 's/eksworkshop-eksctl./eksworkshop-eksctl-dev./g' | tee $KUBECONFIG
```

We just added the `--profile dev` parameter to our kubectl config file, so that this will ask kubectl to use our IAM role associated to our dev profile.

With this configuration we should be able to interract with the **development** namespace, because it as our RBAC role defined.

let's create a pod
```
kubectl run --generator=run-pod/v1 nginx-dev --image=nginx -n development
```

We can list the pods

```
kubectl get pods -n development
```

{{<output>}}
NAME                     READY   STATUS    RESTARTS   AGE
nginx-dev   1/1     Running   0          28h
{{</output>}}

but not in other namespaces

```
kubectl get pods -n integration 
```

{{<output>}}
Error from server (Forbidden): pods is forbidden: User "dev-user" cannot list resource "pods" in API group "" in the namespace "integration"
{{</output>}}

#### Test with integ profile

```
export KUBECONFIG=/tmp/kubeconfig-integ && eksctl utils write-kubeconfig eksworkshop-eksctl
cat $KUBECONFIG | awk "/args:/{print;print \"      - --profile\n      - integ\";next}1" | sed 's/eksworkshop-eksctl./eksworkshop-eksctl-integ./g' | tee $KUBECONFIG
```

let's create a pod
```
kubectl run --generator=run-pod/v1 nginx-integ --image=nginx -n integration
```

We can list the pods

```
kubectl get pods -n integration
```

{{<output>}}
NAME          READY   STATUS    RESTARTS   AGE
nginx-integ   1/1     Running   0          43s
{{</output>}}

but not in other namespaces

```
kubectl get pods -n development 
```

{{<output>}}
Error from server (Forbidden): pods is forbidden: User "integ-user" cannot list resource "pods" in API group "" in the namespace "development"
{{</output>}}


#### Test with admin profile

```
export KUBECONFIG=/tmp/kubeconfig-admin && eksctl utils write-kubeconfig eksworkshop-eksctl
cat $KUBECONFIG | awk "/args:/{print;print \"      - --profile\n      - admin\";next}1" | sed 's/eksworkshop-eksctl./eksworkshop-eksctl-admin./g' | tee $KUBECONFIG
```

let's create a pod in default namespace
```
kubectl run --generator=run-pod/v1 nginx-admin --image=nginx 
```

We can list the pods

```
kubectl get pods 
```

{{<output>}}
NAME          READY   STATUS    RESTARTS   AGE
nginx-integ   1/1     Running   0          43s
{{</output>}}

We can list ALL pods in all namespaces

```
kubectl get pods -A
```

{{<output>}}
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
default       nginx-admin                1/1     Running   0          15s
development   nginx-dev                  1/1     Running   0          11m
integration   nginx-integ                1/1     Running   0          4m29s
kube-system   aws-node-mzbh4             1/1     Running   0          100m
kube-system   aws-node-p7nj7             1/1     Running   0          100m
kube-system   aws-node-v2kg9             1/1     Running   0          100m
kube-system   coredns-85bb8bb6bc-2qbx6   1/1     Running   0          105m
kube-system   coredns-85bb8bb6bc-87ndr   1/1     Running   0          105m
kube-system   kube-proxy-4n5lc           1/1     Running   0          100m
kube-system   kube-proxy-b65xm           1/1     Running   0          100m
kube-system   kube-proxy-pr7k7           1/1     Running   0          100m
{{</output>}}


## Swithing between different contexts

It is possible to merge several kubernetes API access in the same KUBECONFIG file, or just tell Kubectl several file to lookup at once:

```
export KUBECONFIG=/tmp/kubeconfig-dev:/tmp/kubeconfig-integ:/tmp/kubeconfig-admin
```

There is a tool [kubectx / kubens](https://github.com/ahmetb/kubectx) that will help manage KUBECONFIG files with several contexts

```
curl -sSLO https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx && chmod 755 kubectx && sudo mv kubectx /usr/local/bin
```


I can use kubectx to quickly list or swith kubernetes contexts

```
kubectx
```

{{<output>}}
i-0397aa1339e238a99@eksworkshop-eksctl-admin.eu-west-2.eksctl.io
i-0397aa1339e238a99@eksworkshop-eksctl-dev.eu-west-2.eksctl.io
i-0397aa1339e238a99@eksworkshop-eksctl-integ.eu-west-2.eksctl.io
{{</output>}}

## Conclusion

In this module, we have seen how to configure EKS to provide finer access to users combining IAM Groups and Kubernetes RBAC.
You'll be able to create different groups depending on your needs, configure their associated RBAC access in your cluster, and simply add or remove users from 
the group to grand or remove them access to your cluster.

Users will only have to configure their aws cli in order to automatically retrievfe their associated rights in your cluster.