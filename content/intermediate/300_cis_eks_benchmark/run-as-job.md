---
title: "Module 2: Run kube-bench as a K8s job"
weight: 20
draft: false
---

#### Create a job file

Create a job file named `job-eks.yaml` using the command below.

```bash
cat << EOF > job-eks.yaml
---
apiVersion: batch/v1
kind: Job
metadata:
  name: kube-bench
spec:
  template:
    spec:
      hostPID: true
      containers:
        - name: kube-bench
          image: aquasec/kube-bench:latest
          command: ["kube-bench", "--benchmark", "eks-1.0"]
          volumeMounts:
            - name: var-lib-kubelet
              mountPath: /var/lib/kubelet
              readOnly: true
            - name: etc-systemd
              mountPath: /etc/systemd
              readOnly: true
            - name: etc-kubernetes
              mountPath: /etc/kubernetes
              readOnly: true
      restartPolicy: Never
      volumes:
        - name: var-lib-kubelet
          hostPath:
            path: "/var/lib/kubelet"
        - name: etc-systemd
          hostPath:
            path: "/etc/systemd"
        - name: etc-kubernetes
          hostPath:
            path: "/etc/kubernetes"
EOF
```

## Run the job on your cluster

Run the `kube-bench` job on a pod in your cluster using the command below.
```
kubectl apply -f job-eks.yaml
```

## View job assessment results

Find the pod that was created. It should be in the `default` namespace.

```
kubectl get pods --all-namespaces
```

Retrieve the value of this pod and the output report. Note the pod name will be different for your environment.

```
kubectl logs kube-bench-<value>
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

## Cleanup

- Delete the resources

```
kubectl delete -f job-eks.yaml
rm -f job-eks.yaml
```


