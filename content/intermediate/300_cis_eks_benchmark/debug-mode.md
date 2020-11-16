---
title: "Module 3: Run kube-bench in debug mode"
weight: 30
draft: false
---

#### Create a job file

Create a job file named `job-debug-eks.yaml` using the command below.

```bash
cat << EOF > job-debug-eks.yaml
---
apiVersion: batch/v1
kind: Job
metadata:
  name: kube-bench-debug
spec:
  template:
    spec:
      hostPID: true
      containers:
        - name: kube-bench
          image: aquasec/kube-bench:latest
          command: ["kube-bench", "-v", "3", "--logtostderr", "--benchmark", "eks-1.0"]
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
kubectl apply -f job-debug-eks.yaml
```

## View job assessment results

Find the pod that was created. It should be in the `default` namespace.

```
kubectl get pods --all-namespaces
```

Retrieve the value of this pod and the output report. Note the pod name will be different for your environment.

```
kubectl logs kube-bench-debug-<value>
```

##### Output

```
I0715 04:29:42.035103     885 common.go:299] Kubernetes version: "" to Benchmark version: "eks-1.0"
I0715 04:29:42.035137     885 common.go:299] Kubernetes version: "" to Benchmark version: "eks-1.0"
I0715 04:29:42.035144     885 util.go:128] Looking for config specific CIS version "eks-1.0"
I0715 04:29:42.035151     885 util.go:132] Looking for file: cfg/eks-1.0/master.yaml
I0715 04:29:42.035199     885 common.go:240] Using config file: cfg/eks-1.0/config.yaml
I0715 04:29:42.035208     885 common.go:315] Checking if the current node is running master components
I0715 04:29:42.035229     885 util.go:81] ps - proc: "kube-apiserver"
I0715 04:29:42.039926     885 util.go:53] [/bin/ps -C kube-apiserver -o cmd --no-headers]: exit status 1
I0715 04:29:42.039936     885 util.go:88] ps - returning: ""
I0715 04:29:42.039961     885 util.go:229] verifyBin - lines(1)
I0715 04:29:42.039967     885 util.go:231] reFirstWord.Match()

I0715 04:29:42.053377     885 util.go:261] executable 'apiserver' not running
W0715 04:29:42.053395     885 util.go:108] 
Unable to detect running programs for component "apiserver"
The following "master node" programs have been searched, but none of them have been found:
        - kube-apiserver
        - hyperkube apiserver
        - hyperkube kube-apiserver
        - apiserver

These program names are provided in the config.yaml, section 'master.apiserver.bins'
I0715 04:29:42.053409     885 common.go:324] unable to detect running programs for component "apiserver"
I0715 04:29:42.053437     885 root.go:91] == Running node checks ==
I0715 04:29:42.053443     885 common.go:299] Kubernetes version: "" to Benchmark version: "eks-1.0"
I0715 04:29:42.053450     885 util.go:128] Looking for config specific CIS version "eks-1.0"
I0715 04:29:42.053526     885 common.go:240] Using config file: cfg/eks-1.0/config.yaml
I0715 04:29:42.053565     885 common.go:80] Using test file: cfg/eks-1.0/node.yaml
I0715 04:29:42.053587     885 util.go:81] ps - proc: "hyperkube"
I0715 04:29:42.057268     885 util.go:53] [/bin/ps -C hyperkube -o cmd --no-headers]: exit status 1
I0715 04:29:42.057279     885 util.go:88] ps - returning: ""
I0715 04:29:42.057323     885 util.go:229] verifyBin - lines(1)
I0715 04:29:42.057332     885 util.go:231] reFirstWord.Match()
I0715 04:29:42.057337     885 util.go:261] executable 'hyperkube kubelet' not running
I0715 04:29:42.057343     885 util.go:81] ps - proc: "kubelet"
I0715 04:29:42.061305     885 util.go:88] ps - returning: "/usr/bin/kubelet --cloud-provider aws --config /etc/kubernetes/kubelet/kubelet-config.json --kubeconfig /var/lib/kubelet/kubeconfig --container-runtime docker --network-plugin cni --node-ip=192.168.84.9 --pod-infra-container-image=602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/pause-amd64:3.1 --node-labels=alpha.eksctl.io/cluster-name=eksworkshop-eksctl,alpha.eksctl.io/nodegroup-name=nodegroup,eks.amazonaws.com/nodegroup=nodegroup,eks.amazonaws.com/nodegroup-image=ami-03cb83c4dfe25bd99\n"
I0715 04:29:42.061341     885 util.go:229] verifyBin - lines(2)
I0715 04:29:42.061356     885 util.go:231] reFirstWord.Match(/usr/bin/kubelet --cloud-provider aws --config /etc/kubernetes/kubelet/kubelet-config.json --kubeconfig /var/lib/kubelet/kubeconfig --container-runtime docker --network-plugin cni --node-ip=192.168.84.9 --pod-infra-container-image=602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/pause-amd64:3.1 --node-labels=alpha.eksctl.io/cluster-name=eksworkshop-eksctl,alpha.eksctl.io/nodegroup-name=nodegroup,eks.amazonaws.com/nodegroup=nodegroup,eks.amazonaws.com/nodegroup-image=ami-03cb83c4dfe25bd99)

I0715 04:29:42.065192     885 util.go:195] Using default config file name '/etc/kubernetes/config' for component kubernetes
I0715 04:29:42.065212     885 util.go:202] Component kubelet uses service file '/etc/systemd/system/kubelet.service'
 "{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"574Mi\"\n  },\n  \"maxPods\": 29\n}\n"
 - Error Messages:"" 
I0715 04:29:42.121877     885 check.go:187] Check.ID: 3.2.11 Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json" TestResult: true State: "PASS" 
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
kubectl delete -f job-debug-eks.yaml
rm -f job-debug-eks.yaml
```


