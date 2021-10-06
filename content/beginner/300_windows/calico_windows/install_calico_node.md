---
title: "Install Calico on the Windows node"
date: 2018-11-08T08:30:11-07:00
weight: 2
---

In this module, we will install Calico on the windows node.

List Amazon EKS cluster nodes and find the windows node.

```
kubectl get nodes -l kubernetes.io/os=windows -L kubernetes.io/os
```

{{< output >}}
NAME                                          STATUS   ROLES    AGE   VERSION               OS
ip-192-168-5-189.us-east-2.compute.internal   Ready    <none>   25m   v1.17.12-eks-7684af   windows
{{< /output >}}

SSH into nodes using SSM via the AWS Console by finding the windows node in the list of [running EC2 instances](https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Instances:instanceState=running), select the instance named "eksworkshop-eksctl-windows-ng-Node" and click Connect

![Windows EC2 node](/images/windows/windows_select_node.png)

Then select 'Session Manager' and connect

![EC2 Connect Session Manager](/images/windows/ssm_connect.png)


This will open a new browser tab with a powershell prompt on the Node. Now we will use that Powershell window to install kubectl on the node

```
mkdir c:\k
Invoke-WebRequest https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.12/2020-11-02/bin/windows/amd64/kubectl.exe -OutFile c:\k\kubectl.exe
$ENV:PATH += ";C:\k"
```

Now we will download and install Calico

```
Invoke-WebRequest https://docs.projectcalico.org/scripts/install-calico-windows.ps1 -OutFile c:\install-calico-windows.ps1
C:/install-calico-windows.ps1 -ServiceCidr 10.100.0.0/16 -DNSServerIPs 10.100.0.10
```

Verify the install

```
Get-Service -Name Calico*, kube*
```

We should get the following output:

{{< output >}}
Status   Name            DisplayName
------   ----            ------------
Running  CalicoNode      Calico Windows Startup
Running  CalicoFelix     Calico Windows Agent
Running  kubelet         kubelet service
Running  kube-proxy      kube-proxy service
{{< /output >}}

Now we have Calcio fully installed. Close the EC2 Connect window and return to Cloud9.