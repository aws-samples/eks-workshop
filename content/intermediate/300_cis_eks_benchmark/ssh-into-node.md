---
title: "Module 1: Install kube-bench in node"
weight: 15
draft: false
---

In this module, we will install `kube-bench` in one of the nodes and run the CIS Amazon EKS Benchmark node assessment against `eks-1.0` node controls.


#### List Amazon EKS cluster nodes

```
kubectl get nodes -o wide
```

##### Output
```
NAME                                           STATUS   ROLES    AGE   VERSION                INTERNAL-IP      EXTERNAL-IP      OS-IMAGE         KERNEL-VERSION                  CONTAINER-RUNTIME
ip-192-168-17-56.us-west-2.compute.internal    Ready    <none>   24h   v1.16.12-eks-904af05   192.168.17.56    34.220.140.125   Amazon Linux 2   4.14.181-142.260.amzn2.x86_64   docker://19.3.6
ip-192-168-45-110.us-west-2.compute.internal   Ready    <none>   24h   v1.16.12-eks-904af05   192.168.45.110   34.220.227.8     Amazon Linux 2   4.14.181-142.260.amzn2.x86_64   docker://19.3.6
ip-192-168-84-9.us-west-2.compute.internal     Ready    <none>   24h   v1.16.12-eks-904af05   192.168.84.9     34.210.27.208    Amazon Linux 2   4.14.181-142.260.amzn2.x86_64   docker://19.3.6
```

#### SSH into nodes

* Ssh (using SSM) via the AWS Console by clicking 'Connect'->'Session Manager`

#### Install `kube-bench`

Install `kube-bench` using the commands below.

- Set latest version
```
KUBEBENCH_URL=$(curl -s https://api.github.com/repos/aquasecurity/kube-bench/releases/latest | jq -r '.assets[] | select(.name | contains("amd64.rpm")) | .browser_download_url')
```
- Download and install kube-bench using yum 
```
sudo yum install -y $KUBEBENCH_URL
```

#### Run assessment against `eks-1.0`

Run the assessment against `eks-1.0` controls based on CIS Amazon EKS Benchmark node assessments.

```
kube-bench --benchmark eks-1.0
```

##### Output

```
[INFO] 3 Worker Node Security Configuration
[INFO] 3.1 Worker Node Configuration Files
[PASS] 3.1.1 Ensure that the proxy kubeconfig file permissions are set to 644 or more restrictive (Scored)
[PASS] 3.1.2 Ensure that the proxy kubeconfig file ownership is set to root:root (Scored)
[PASS] 3.1.3 Ensure that the kubelet configuration file has permissions set to 644 or more restrictive (Scored)
[PASS] 3.1.4 Ensure that the kubelet configuration file ownership is set to root:root (Scored)
[INFO] 3.2 Kubelet
[PASS] 3.2.1 Ensure that the --anonymous-auth argument is set to false (Scored)
[PASS] 3.2.2 Ensure that the --authorization-mode argument is not set to AlwaysAllow (Scored)
[PASS] 3.2.3 Ensure that the --client-ca-file argument is set as appropriate (Scored)
[PASS] 3.2.4 Ensure that the --read-only-port argument is set to 0 (Scored)
[PASS] 3.2.5 Ensure that the --streaming-connection-idle-timeout argument is not set to 0 (Scored)
[PASS] 3.2.6 Ensure that the --protect-kernel-defaults argument is set to true (Scored)
[PASS] 3.2.7 Ensure that the --make-iptables-util-chains argument is set to true (Scored) 
[PASS] 3.2.8 Ensure that the --hostname-override argument is not set (Scored)
[WARN] 3.2.9 Ensure that the --event-qps argument is set to 0 or a level which ensures appropriate event capture (Scored)
[PASS] 3.2.10 Ensure that the --rotate-certificates argument is not set to false (Scored)
[PASS] 3.2.11 Ensure that the RotateKubeletServerCertificate argument is set to true (Scored)

== Remediations ==
3.2.9 If using a Kubelet config file, edit the file to set eventRecordQPS: to an appropriate level.
If using command line arguments, edit the kubelet service file
/etc/systemd/system/kubelet.service on each worker node and
set the below parameter in KUBELET_SYSTEM_PODS_ARGS variable.
Based on your system, restart the kubelet service. For example:
systemctl daemon-reload
systemctl restart kubelet.service


== Summary ==
14 checks PASS
0 checks FAIL
1 checks WARN
0 checks INFO
```



#### Clean-up

- Uninstall kube-bench

```
sudo yum remove kube-bench -y
```

- Exit out of the node
```
exit
```


