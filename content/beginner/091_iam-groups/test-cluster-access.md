---
title: "Test EKS access"
date: 2020-04-05T18:00:00-00:00
draft: false
weight: 40
---

## Manually test assumed role

In order to access the cluster, our users will need to be able to assume the role they need to access the cluster.

<details>
  <summary>Let's remind us how this works:</summary>
  

In order to see how this works, we can manually assume the role from our dev user

```
ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')
source ~/.aws/JeanDev_creds.sh
```

Try to assume the k8sInteg role:
```
$ aws sts assume-role --role-arn arn:aws:iam::${ACCOUNT_ID}:role/k8sInteg --role-session-name integ-role-session

An error occurred (AccessDenied) when calling the AssumeRole operation: User: arn:aws:iam::xxxxxxxxx:user/jeanDev is not authorized to perform: sts:AssumeRole on resource: arn:aws:iam::xxxxxxxx:role/k8sInteg
```

> This is forbidden as expected, dev user can only assume k8sDev role.

Let's assume the k8sDev role:
```
aws sts assume-role --role-arn arn:aws:iam::${ACCOUNT_ID}:role/k8sDev --role-session-name dev-role-session|cat
{
    "Credentials": {
        "AccessKeyId": "ASIAUD5VMKW767UVE7VY",
        "SecretAccessKey": "p3zTwD1LiEjy9h78Jr0RUDxNYGc11olWeeIrDCys",
        "SessionToken": "IQoJb3JpZ2luX2VjEBsaCXVzLWVhc3QtMSJHMEUCIQCQb4j/ivn33VPexIgebG7T5ECuOMt65ZFdRiTrcGwDcgIgdmdGwxkINntUxAvZIbG6+VBZLdmTsamHHTWO5SsF4pUq4AEI0///////////ARAAGgwyODMzMTEzNjM1MTkiDHznfNb55njGhX6gQSq0ASzCu6KSBSgWU2ryFIS+XdwPVzYeVIMyx5ixcqJC/xZcRVDhGWLRV0TMKUwOn1Vw1pjilOjoxpjTStWeFHaRpXp2jTs6eGc5xA8lQ7aFNXEl+neANqTvnsk3QRLiMPuaoDdkWY6UfEYyj3gbKzj1lKcbF8C/mJUDn9oe0YU9VnYoi9DvnzuLW+rC1InC5QBHOaB2VUsdRh36MNacglR5TPOv2FnslasRp4A3gjWA61zvS+WTDK7a7yBTrjAaJhxmZbCxVbVmEoT3JrPsx4i94NilSQDFuItCOdBVIwfK+uIAfKSgj5BqpjHl6b4Io8a03FmVaiUs87lnc3/f9d/c7RIiP7wbM0cz3tt1MfqhxTbmWmDZ9VLwjgXJZjaNqfPht3PnplW9CkzaAasUytDdzPCO1yc9lU2THoGBbE1Q9ZLor2a/prVZvz8+vxZ3XtNe+uobvSlQwPxoHxF/3badjq9agOoSLLaNBCU2xJOmreYhbLfzR0Nwdx2wTa9oChcxSzIhc8cd3hDY1LFRfjwMBLC1JiAQWdDFJ5wcHCh29B",
        "Expiration": "2020-02-18T11:04:58+00:00"
    },
    "AssumedRoleUser": {
        "AssumedRoleId": "AROAUD5VMKW77O3CKTAZC:dev-role-session",
        "Arn": "arn:aws:sts::xxxxxxxx:assumed-role/k8sDev/dev-role-session"
    }
}
```

> This provide us some temporary credentials which uses the policy associated to the assumed role, and will give us access to the kubernetes API.
</details>


## Automate assumerole with aws cli

It is possible to automate the retrieval of temporary credentials for the assumed role by configuring the aws cli using `.aws/config`and `.aws/credentials` files.
Examples we will define 3 profile:

add in `~/.aws/config`:
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

> replace xxxxxx with your $ACCOUNT_ID

```
cat << EoF >> ~/.aws/credential

[eksAdmin]
aws_access_key_id=$(jq .AccessKey.AccessKeyId /tmp/PaulAdmin.json)
aws_secret_access_key=$(jq .AccessKey.SecretAccessKey /tmp/PaulAdmin.json)

[eksDev]
aws_access_key_id=$(jq .AccessKey.AccessKeyId /tmp/JeanDev.json)
aws_secret_access_key=$(jq .AccessKey.SecretAccessKey /tmp/JeanDev.json)

[eksInteg]
aws_access_key_id=$(jq .AccessKey.AccessKeyId /tmp/PierreInteg.json)
aws_secret_access_key=$(jq .AccessKey.SecretAccessKey /tmp/PierreInteg.json)

EoF
```

> replace with the credentials you saved in `~.aws` for each of our users.

Test this with dev profile:

```

$ aws sts get-caller-identity --profile dev
{
    "UserId": "AROAUD5VMKW75WJEHFU4X:botocore-session-1581687024",
    "Account": "xxxxxxxxxx",
    "Arn": "arn:aws:sts::xxxxxxxxxx:assumed-role/k8sDev/botocore-session-1581687024"
}
```
> When specifying the **--profile dev** parameter we automatically ask for temporary credentials for the role k8sDev
> 
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

##### Using AWS profiles with Kubectl config file

It is also possible to specify the AWS_PROFILE to uses with the aws-iam-authenticator in the `.kube/config` file, so that it will uses the appropriate profile.

Create new KUBECONFIG file to test this:

```
export KUBECONFIG=/tmp/kubeconfig && eksctl utils write-kubeconfig eksworkshop
```
or
```
export KUBECONFIG=/tmp/kubeconfig && aws eks update-kubeconfig --name eksworkshop
```

Update the `/tmp/kubeconfig` file to allow access with k8sDev profile:

```
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      env:
      - name: "AWS_PROFILE"  # <-- we add AWS_PROFILE env parameter
        value: "dev"         # <-- and the value dev | integ | admin
      args:
        - "token"
        - "-i"
        - "mycluster"
```

We should be able to do what we wants in the **development** namespace:

```
kubectl get pods -n development 
NAME                     READY   STATUS    RESTARTS   AGE
nginx-7db9fccd9b-9kg85   1/1     Running   0          28h
```

If we edit the $KUBECONFIG file and change the AWS_PROFILE for integ user:
```
      - name : "AWS_PROFILE"
        value: "integ"
```

then we should be able to access **integration** namespace only

```
kubectl get pods -n integration
NAME                     READY   STATUS    RESTARTS   AGE
nginx-7db9fccd9b-n5p4v   1/1     Running   0          5d1h
```

It is possible to merge several kubernetes API access in the same KUBECONFIG file, you can do it for example by renaming part of the config and running several times the eksctl `eksctl utils write-kubeconfig quick` command to generate new entry.

In my case, I've done this to generate 3 différentes entries, one for each of the user we created : admin, dev, integ.

I can use a tool like [kubectx](https://github.com/ahmetb/kubectx) to quickly swith my kubernetes user:

```
$ kubectx
eksworkshop.us-east-1.eksctl.io-Admin
eksworkshop.us-east-1.eksctl.io-Dev
eksworkshop.us-east-1.eksctl.io-Integ
```