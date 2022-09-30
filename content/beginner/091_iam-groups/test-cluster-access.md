---
title: "Test EKS access"
date: 2020-04-05T18:00:00-00:00
draft: false
weight: 40
---

## Automate assumerole with aws cli

It is possible to automate the retrieval of temporary credentials for the assumed role by configuring the AWS CLI in the files `~/.aws/config` and `~/.aws/credentials`.
As an example, we will define three profiles.

#### Add in `~/.aws/config`:

```bash
mkdir -p ~/.aws

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

#### Add in `~/.aws/credentials`:

```bash
cat << EoF >> ~/.aws/credentials

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

#### Test this with the dev profile:

```bash
aws sts get-caller-identity --profile dev
```

{{<output>}}
{
    "UserId": "AROAUD5VMKW75WJEHFU4X:botocore-session-1581687024",
    "Account": "xxxxxxxxxx",
    "Arn": "arn:aws:sts::xxxxxxxxxx:assumed-role/k8sDev/botocore-session-1581687024"
}
{{</output>}}

The assumed-role is k8sDev, so we achieved our goal.

When specifying the **--profile dev** parameter we automatically ask for temporary credentials for the role k8sDev.
You can test this with **integ** and **admin** also.
 
<details>
  <summary>With admin:</summary>
  
```bash
aws sts get-caller-identity --profile admin
```

{{<output>}}
{
    "UserId": "AROAUD5VMKW77KXQAL7ZX:botocore-session-1582022121",
    "Account": "xxxxxxxxxx",
    "Arn": "arn:aws:sts::xxxxxxxxxx:assumed-role/k8sAdmin/botocore-session-1582022121"
}
{{</output>}}

> When specifying the **--profile admin** parameter we automatically ask for temporary credentials for the role k8sAdmin
</details>

## Using AWS profiles with the Kubectl config file

It is also possible to specify the AWS_PROFILE to use with the aws-iam-authenticator in the `~/.kube/config` file, so that it will use the appropriate profile.

### With dev profile

Create a new KUBECONFIG file to test this:

```bash
export KUBECONFIG=/tmp/kubeconfig-dev && eksctl utils write-kubeconfig --cluster eksworkshop-eksctl
cat $KUBECONFIG | yq e '.users.[].user.exec.args += ["--profile", "dev"]' - -- | sed 's/eksworkshop-eksctl./eksworkshop-eksctl-dev./g' | sponge $KUBECONFIG
```

> Note: this assume you uses yq >= version 4. you can reference to [this page](https://mikefarah.gitbook.io/yq/upgrading-from-v3) to adapt this command for another version.

We added the `--profile dev` parameter to our kubectl config file, so that this will ask kubectl to use our IAM role associated to our dev profile, and we rename the context using suffix **-dev**.

With this configuration we should be able to interact with the **development** namespace, because it has our RBAC role defined.

Let's create a pod:

```bash
kubectl run nginx-dev --image=nginx -n development
```
> Note: If you are getting an error "The connection to the server localhost:8080 was refused - did you specify the right host or port?", its possible that you have not cleaned up the environment from a previous lab. Please follow the steps required to clean up and then retry. 

We can list the pods:

```bash
kubectl get pods -n development
```

{{<output>}}
NAME                     READY   STATUS    RESTARTS   AGE
nginx-dev   1/1     Running   0          28h
{{</output>}}

... but not in other namespaces:

```bash
kubectl get pods -n integration
```

{{<output>}}
Error from server (Forbidden): pods is forbidden: User "dev-user" cannot list resource "pods" in API group "" in the namespace "integration"
{{</output>}}

#### Test with integ profile

```bash
export KUBECONFIG=/tmp/kubeconfig-integ && eksctl utils write-kubeconfig --cluster=eksworkshop-eksctl
cat $KUBECONFIG | yq e '.users.[].user.exec.args += ["--profile", "integ"]' - -- | sed 's/eksworkshop-eksctl./eksworkshop-eksctl-integ./g' | sponge $KUBECONFIG
```

> Note: this assume you uses yq >= version 4. you can reference to [this page](https://mikefarah.gitbook.io/yq/upgrading-from-v3) to adapt this command for another version.

Let's create a pod:

```bash
kubectl run nginx-integ --image=nginx -n integration
```

We can list the pods:

```bash
kubectl get pods -n integration
```

{{<output>}}
NAME          READY   STATUS    RESTARTS   AGE
nginx-integ   1/1     Running   0          43s
{{</output>}}

... but not in other namespaces:

```bash
kubectl get pods -n development
```

{{<output>}}
Error from server (Forbidden): pods is forbidden: User "integ-user" cannot list resource "pods" in API group "" in the namespace "development"
{{</output>}}

#### Test with admin profile

```bash
export KUBECONFIG=/tmp/kubeconfig-admin && eksctl utils write-kubeconfig --cluster=eksworkshop-eksctl
cat $KUBECONFIG | yq e '.users.[].user.exec.args += ["--profile", "admin"]' - -- | sed 's/eksworkshop-eksctl./eksworkshop-eksctl-admin./g' | sponge $KUBECONFIG
```

> Note: this assume you uses yq >= version 4. you can reference to [this page](https://mikefarah.gitbook.io/yq/upgrading-from-v3) to adapt this command for another version.

Let's create a pod in the default namespace:

```bash
kubectl run nginx-admin --image=nginx
```

We can list the pods:

```bash
kubectl get pods
```

{{<output>}}
NAME          READY   STATUS    RESTARTS   AGE
nginx-integ   1/1     Running   0          43s
{{</output>}}

We can list ALL pods in all namespaces:

```bash
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

## Switching between different contexts

It is possible to configure several Kubernetes API access keys in the same KUBECONFIG file, or just tell Kubectl to lookup several files:

```bash
export KUBECONFIG=/tmp/kubeconfig-dev:/tmp/kubeconfig-integ:/tmp/kubeconfig-admin
```

There is a tool [kubectx / kubens](https://github.com/ahmetb/kubectx) that will help manage KUBECONFIG files with several contexts:

```bash
curl -sSLO https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx && chmod 755 kubectx && sudo mv kubectx /usr/local/bin
```

I can use kubectx to quickly list or switch Kubernetes contexts:

```bash
kubectx
```

{{<output>}}
i-0397aa1339e238a99@eksworkshop-eksctl-admin.eu-west-2.eksctl.io
i-0397aa1339e238a99@eksworkshop-eksctl-dev.eu-west-2.eksctl.io
i-0397aa1339e238a99@eksworkshop-eksctl-integ.eu-west-2.eksctl.io
{{</output>}}

## Conclusion

In this module, we have seen how to configure EKS to provide finer access to users combining IAM Groups and Kubernetes RBAC.
You can create different groups depending on your needs, configure their associated RBAC access in your cluster, and simply add or remove users from the group to grant or revoke access to your cluster.

Users will only have to configure their AWS CLI in order to automatically retrieve their associated rights in your cluster.

