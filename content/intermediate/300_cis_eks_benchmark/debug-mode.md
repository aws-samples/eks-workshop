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
I1006 22:25:12.262300   26126 util.go:472] Checking for oc
I1006 22:25:12.262391   26126 util.go:501] Can't find oc command: exec: "oc": executable file not found in $PATH
I1006 22:25:12.262415   26126 kubernetes_version.go:36] Try to get version from Rest API
I1006 22:25:12.262464   26126 kubernetes_version.go:162] Loading CA certificate
I1006 22:25:12.262487   26126 kubernetes_version.go:115] getWebData srvURL: https://kubernetes.default.svc/version
I1006 22:25:12.262521   26126 kubernetes_version.go:131] getWebData AUTH TOKEN --["redacted"]--
I1006 22:25:12.293485   26126 kubernetes_version.go:100] vd: {
  "major": "1",
  "minor": "20+",
  "gitVersion": "v1.20.7-eks-d88609",
  "gitCommit": "d886092805d5cc3a47ed5cf0c43de38ce442dfcb",
  "gitTreeState": "clean",
  "buildDate": "2021-07-31T00:29:12Z",
  "goVersion": "go1.15.12",
  "compiler": "gc",
  "platform": "linux/amd64"
}
I1006 22:25:12.293640   26126 kubernetes_version.go:105] vrObj: &cmd.VersionResponse{Major:"1", Minor:"20+", GitVersion:"v1.20.7-eks-d88609", GitCommit:"d886092805d5cc3a47ed5cf0c43de38ce442dfcb", GitTreeState:"clean", BuildDate:"2021-07-31T00:29:12Z", GoVersion:"go1.15.12", Compiler:"gc", Platform:"linux/amd64"}
I1006 22:25:12.293671   26126 util.go:286] Kubernetes REST API Reported version: &{1 20+  v1.20.7-eks-d88609}
I1006 22:25:12.293770   26126 common.go:351] Kubernetes version: "" to Benchmark version: "eks-1.0"
I1006 22:25:12.293785   26126 root.go:76] Running checks for benchmark eks-1.0
I1006 22:25:12.293790   26126 common.go:366] Checking if the current node is running master components
I1006 22:25:12.293819   26126 util.go:70] ps - proc: "kube-apiserver"
I1006 22:25:12.299827   26126 util.go:74] [/bin/ps -C kube-apiserver -o cmd --no-headers]: exit status 1
I1006 22:25:12.299844   26126 util.go:77] ps - returning: ""
I1006 22:25:12.299873   26126 util.go:219] reFirstWord.Match()
I1006 22:25:12.299879   26126 util.go:249] executable 'kube-apiserver' not running
I1006 22:25:12.299886   26126 util.go:70] ps - proc: "hyperkube"
I1006 22:25:12.304459   26126 util.go:74] [/bin/ps -C hyperkube -o cmd --no-headers]: exit status 1
I1006 22:25:12.304472   26126 util.go:77] ps - returning: ""
I1006 22:25:12.304529   26126 util.go:219] reFirstWord.Match()
I1006 22:25:12.304535   26126 util.go:249] executable 'hyperkube apiserver' not running
I1006 22:25:12.304542   26126 util.go:70] ps - proc: "hyperkube"
I1006 22:25:12.311191   26126 util.go:74] [/bin/ps -C hyperkube -o cmd --no-headers]: exit status 1
I1006 22:25:12.311207   26126 util.go:77] ps - returning: ""
I1006 22:25:12.311249   26126 util.go:219] reFirstWord.Match()
I1006 22:25:12.311256   26126 util.go:249] executable 'hyperkube kube-apiserver' not running
I1006 22:25:12.311263   26126 util.go:70] ps - proc: "apiserver"
I1006 22:25:12.316878   26126 util.go:74] [/bin/ps -C apiserver -o cmd --no-headers]: exit status 1
I1006 22:25:12.316897   26126 util.go:77] ps - returning: ""
I1006 22:25:12.316923   26126 util.go:219] reFirstWord.Match()
I1006 22:25:12.316931   26126 util.go:249] executable 'apiserver' not running
I1006 22:25:12.316940   26126 util.go:70] ps - proc: "openshift"
I1006 22:25:12.321517   26126 util.go:74] [/bin/ps -C openshift -o cmd --no-headers]: exit status 1
I1006 22:25:12.321532   26126 util.go:77] ps - returning: ""
I1006 22:25:12.321564   26126 util.go:219] reFirstWord.Match()
I1006 22:25:12.321572   26126 util.go:249] executable 'openshift start master api' not running
I1006 22:25:12.321580   26126 util.go:70] ps - proc: "hypershift"
I1006 22:25:12.326144   26126 util.go:74] [/bin/ps -C hypershift -o cmd --no-headers]: exit status 1
I1006 22:25:12.326161   26126 util.go:77] ps - returning: ""
I1006 22:25:12.326224   26126 util.go:219] reFirstWord.Match()
I1006 22:25:12.326230   26126 util.go:249] executable 'hypershift openshift-kube-apiserver' not running
I1006 22:25:12.326246   26126 util.go:97]
Unable to detect running programs for component "apiserver"
The following "master node" programs have been searched, but none of them have been found:
	- kube-apiserver
	- hyperkube apiserver
	- hyperkube kube-apiserver
	- apiserver
	- openshift start master api
	- hypershift openshift-kube-apiserver


These program names are provided in the config.yaml, section 'master.apiserver.bins'
I1006 22:25:12.326254   26126 common.go:375] Failed to find master binaries: unable to detect running programs for component "apiserver"
I1006 22:25:12.326263   26126 root.go:93] == Skipping master checks ==
I1006 22:25:12.326300   26126 root.go:106] == Skipping etcd checks ==
I1006 22:25:12.326307   26126 root.go:109] == Running node checks ==
I1006 22:25:12.326313   26126 util.go:117] Looking for config specific CIS version "eks-1.0"
I1006 22:25:12.326325   26126 util.go:121] Looking for file: cfg/eks-1.0/node.yaml
I1006 22:25:12.326487   26126 common.go:274] Using config file: cfg/eks-1.0/config.yaml
I1006 22:25:12.326539   26126 common.go:79] Using test file: cfg/eks-1.0/node.yaml
I1006 22:25:12.326559   26126 util.go:70] ps - proc: "hyperkube"
I1006 22:25:12.330777   26126 util.go:74] [/bin/ps -C hyperkube -o cmd --no-headers]: exit status 1
I1006 22:25:12.330794   26126 util.go:77] ps - returning: ""
I1006 22:25:12.330834   26126 util.go:219] reFirstWord.Match()
I1006 22:25:12.330847   26126 util.go:249] executable 'hyperkube kubelet' not running
I1006 22:25:12.330854   26126 util.go:70] ps - proc: "kubelet"
I1006 22:25:12.335001   26126 util.go:77] ps - returning: "/usr/bin/kubelet --cloud-provider aws --config /etc/kubernetes/kubelet/kubelet-config.json --kubeconfig /var/lib/kubelet/kubeconfig --container-runtime docker --network-plugin cni --node-ip=192.168.69.155 --pod-infra-container-image=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/pause:3.1-eksbuild.1 --v=2 --node-labels=eks.amazonaws.com/sourceLaunchTemplateVersion=1,alpha.eksctl.io/cluster-name=eksworkshop-eksctl,alpha.eksctl.io/nodegroup-name=nodegroup,eks.amazonaws.com/nodegroup-image=ami-0b8ee6712a546f246,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=nodegroup,eks.amazonaws.com/sourceLaunchTemplateId=lt-04698ac31da975ca2\n"
I1006 22:25:12.335043   26126 util.go:219] reFirstWord.Match(/usr/bin/kubelet --cloud-provider aws --config /etc/kubernetes/kubelet/kubelet-config.json --kubeconfig /var/lib/kubelet/kubeconfig --container-runtime docker --network-plugin cni --node-ip=192.168.69.155 --pod-infra-container-image=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/pause:3.1-eksbuild.1 --v=2 --node-labels=eks.amazonaws.com/sourceLaunchTemplateVersion=1,alpha.eksctl.io/cluster-name=eksworkshop-eksctl,alpha.eksctl.io/nodegroup-name=nodegroup,eks.amazonaws.com/nodegroup-image=ami-0b8ee6712a546f246,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=nodegroup,eks.amazonaws.com/sourceLaunchTemplateId=lt-04698ac31da975ca2)
I1006 22:25:12.335062   26126 util.go:106] Component kubelet uses running binary kubelet
I1006 22:25:12.335084   26126 util.go:70] ps - proc: "kube-proxy"
I1006 22:25:12.339257   26126 util.go:77] ps - returning: "kube-proxy --v=2 --config=/var/lib/kube-proxy-config/config\n"
I1006 22:25:12.339305   26126 util.go:219] reFirstWord.Match(kube-proxy --v=2 --config=/var/lib/kube-proxy-config/config)
I1006 22:25:12.339318   26126 util.go:106] Component proxy uses running binary kube-proxy
I1006 22:25:12.339367   26126 util.go:191] Component kubelet uses config file '/etc/kubernetes/kubelet/kubelet-config.json'
I1006 22:25:12.339397   26126 util.go:184] Using default config file name '/etc/kubernetes/addons/kube-proxy-daemonset.yaml' for component proxy
I1006 22:25:12.339405   26126 util.go:184] Using default config file name '/etc/kubernetes/config' for component kubernetes
I1006 22:25:12.339427   26126 util.go:191] Component kubelet uses service file '/etc/systemd/system/kubelet.service'
I1006 22:25:12.339446   26126 util.go:187] Missing service file for proxy
I1006 22:25:12.339470   26126 util.go:187] Missing service file for kubernetes
I1006 22:25:12.339494   26126 util.go:191] Component kubelet uses kubeconfig file '/var/lib/kubelet/kubeconfig'
I1006 22:25:12.339517   26126 util.go:191] Component proxy uses kubeconfig file '/var/lib/kubelet/kubeconfig'
I1006 22:25:12.339524   26126 util.go:187] Missing kubeconfig file for kubernetes
I1006 22:25:12.339538   26126 util.go:191] Component kubelet uses ca file '/etc/kubernetes/pki/ca.crt'
I1006 22:25:12.339546   26126 util.go:187] Missing ca file for proxy
I1006 22:25:12.339554   26126 util.go:187] Missing ca file for kubernetes
I1006 22:25:12.339583   26126 util.go:382] Substituting $kubeletbin with 'kubelet'
I1006 22:25:12.339606   26126 util.go:382] Substituting $proxybin with 'kube-proxy'
I1006 22:25:12.339614   26126 util.go:382] Substituting $kubeletconf with '/etc/kubernetes/kubelet/kubelet-config.json'
I1006 22:25:12.339636   26126 util.go:382] Substituting $proxyconf with '/etc/kubernetes/addons/kube-proxy-daemonset.yaml'
I1006 22:25:12.339646   26126 util.go:382] Substituting $kubernetesconf with '/etc/kubernetes/config'
I1006 22:25:12.339652   26126 util.go:382] Substituting $kubeletsvc with '/etc/systemd/system/kubelet.service'
I1006 22:25:12.339674   26126 util.go:382] Substituting $proxysvc with 'proxy'
I1006 22:25:12.339681   26126 util.go:382] Substituting $kubernetessvc with 'kubernetes'
I1006 22:25:12.339693   26126 util.go:382] Substituting $kubeletkubeconfig with '/var/lib/kubelet/kubeconfig'
I1006 22:25:12.339703   26126 util.go:382] Substituting $proxykubeconfig with '/var/lib/kubelet/kubeconfig'
I1006 22:25:12.339726   26126 util.go:382] Substituting $kuberneteskubeconfig with 'kubernetes'
I1006 22:25:12.339733   26126 util.go:382] Substituting $kubeletcafile with '/etc/kubernetes/pki/ca.crt'
I1006 22:25:12.339739   26126 util.go:382] Substituting $proxycafile with 'proxy'
I1006 22:25:12.339744   26126 util.go:382] Substituting $kubernetescafile with 'kubernetes'
I1006 22:25:12.342412   26126 check.go:110] -----   Running check 3.1.1   -----
I1006 22:25:12.343763   26126 check.go:299] Command: "/bin/sh -c 'if test -e /var/lib/kubelet/kubeconfig; then stat -c %a /var/lib/kubelet/kubeconfig; fi'"
I1006 22:25:12.343780   26126 check.go:300] Output:
 "644\n"
I1006 22:25:12.343788   26126 check.go:221] Running 7 test_items
I1006 22:25:12.343830   26126 test.go:151] In flagTestItem.findValue 644
I1006 22:25:12.343870   26126 test.go:245] Flag '644' exists
I1006 22:25:12.343875   26126 check.go:245] Used auditCommand
I1006 22:25:12.343889   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.343894   26126 test.go:245] Flag '640' does not exist
I1006 22:25:12.343898   26126 check.go:245] Used auditCommand
I1006 22:25:12.343903   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.343926   26126 test.go:245] Flag '600' does not exist
I1006 22:25:12.343944   26126 check.go:245] Used auditCommand
I1006 22:25:12.343951   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.343957   26126 test.go:245] Flag '444' does not exist
I1006 22:25:12.343961   26126 check.go:245] Used auditCommand
I1006 22:25:12.343966   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.343972   26126 test.go:245] Flag '440' does not exist
I1006 22:25:12.343976   26126 check.go:245] Used auditCommand
I1006 22:25:12.343980   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.343986   26126 test.go:245] Flag '400' does not exist
I1006 22:25:12.343990   26126 check.go:245] Used auditCommand
I1006 22:25:12.343994   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.343999   26126 test.go:245] Flag '000' does not exist
I1006 22:25:12.344004   26126 check.go:245] Used auditCommand
I1006 22:25:12.344034   26126 check.go:277] Returning from execute on tests: finalOutput &check.testOutput{testResult:true, flagFound:false, actualResult:"644", ExpectedResult:"'644' is equal to '644' OR '640' is present OR '600' is present OR '444' is present OR '440' is present OR '400' is present OR '000' is present"}
I1006 22:25:12.344060   26126 check.go:184] Command: "" TestResult: true State: "PASS"
I1006 22:25:12.344071   26126 check.go:110] -----   Running check 3.1.2   -----
I1006 22:25:12.345293   26126 check.go:299] Command: "/bin/sh -c 'if test -e /var/lib/kubelet/kubeconfig; then stat -c %U:%G /var/lib/kubelet/kubeconfig; fi'"
I1006 22:25:12.345308   26126 check.go:300] Output:
 "root:root\n"
I1006 22:25:12.345314   26126 check.go:221] Running 1 test_items
I1006 22:25:12.345350   26126 test.go:151] In flagTestItem.findValue root:root
I1006 22:25:12.345375   26126 test.go:245] Flag 'root:root' exists
I1006 22:25:12.345380   26126 check.go:245] Used auditCommand
I1006 22:25:12.345386   26126 check.go:277] Returning from execute on tests: finalOutput &check.testOutput{testResult:true, flagFound:false, actualResult:"root:root", ExpectedResult:"'root:root' is present"}
I1006 22:25:12.345399   26126 check.go:184] Command: "" TestResult: true State: "PASS"
I1006 22:25:12.345407   26126 check.go:110] -----   Running check 3.1.3   -----
I1006 22:25:12.346472   26126 check.go:299] Command: "/bin/sh -c 'if test -e /etc/kubernetes/kubelet/kubelet-config.json; then stat -c %a /etc/kubernetes/kubelet/kubelet-config.json; fi'"
I1006 22:25:12.346487   26126 check.go:300] Output:
 "644\n"
I1006 22:25:12.346494   26126 check.go:221] Running 7 test_items
I1006 22:25:12.346526   26126 test.go:151] In flagTestItem.findValue 644
I1006 22:25:12.346551   26126 test.go:245] Flag '644' exists
I1006 22:25:12.346556   26126 check.go:245] Used auditCommand
I1006 22:25:12.346563   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.346569   26126 test.go:245] Flag '640' does not exist
I1006 22:25:12.346573   26126 check.go:245] Used auditCommand
I1006 22:25:12.346578   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.346583   26126 test.go:245] Flag '600' does not exist
I1006 22:25:12.346587   26126 check.go:245] Used auditCommand
I1006 22:25:12.346591   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.346597   26126 test.go:245] Flag '444' does not exist
I1006 22:25:12.346601   26126 check.go:245] Used auditCommand
I1006 22:25:12.346622   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.346640   26126 test.go:245] Flag '440' does not exist
I1006 22:25:12.346646   26126 check.go:245] Used auditCommand
I1006 22:25:12.346651   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.346657   26126 test.go:245] Flag '400' does not exist
I1006 22:25:12.346661   26126 check.go:245] Used auditCommand
I1006 22:25:12.346666   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.346672   26126 test.go:245] Flag '000' does not exist
I1006 22:25:12.346676   26126 check.go:245] Used auditCommand
I1006 22:25:12.346682   26126 check.go:277] Returning from execute on tests: finalOutput &check.testOutput{testResult:true, flagFound:false, actualResult:"644", ExpectedResult:"'644' is equal to '644' OR '640' is present OR '600' is present OR '444' is present OR '440' is present OR '400' is present OR '000' is present"}
I1006 22:25:12.346696   26126 check.go:184] Command: "" TestResult: true State: "PASS"
I1006 22:25:12.346719   26126 check.go:110] -----   Running check 3.1.4   -----
I1006 22:25:12.347825   26126 check.go:299] Command: "/bin/sh -c 'if test -e /etc/kubernetes/kubelet/kubelet-config.json; then stat -c %U:%G /etc/kubernetes/kubelet/kubelet-config.json; fi'"
I1006 22:25:12.347840   26126 check.go:300] Output:
 "root:root\n"
I1006 22:25:12.347845   26126 check.go:221] Running 1 test_items
I1006 22:25:12.347941   26126 test.go:151] In flagTestItem.findValue root:root
I1006 22:25:12.347950   26126 test.go:245] Flag 'root:root' exists
I1006 22:25:12.347981   26126 check.go:245] Used auditCommand
I1006 22:25:12.347990   26126 check.go:277] Returning from execute on tests: finalOutput &check.testOutput{testResult:true, flagFound:false, actualResult:"root:root", ExpectedResult:"'root:root' is present"}
I1006 22:25:12.348001   26126 check.go:184] Command: "" TestResult: true State: "PASS"
I1006 22:25:12.348010   26126 check.go:110] -----   Running check 3.2.1   -----
I1006 22:25:12.353124   26126 check.go:299] Command: "/bin/ps -fC kubelet"
I1006 22:25:12.353139   26126 check.go:300] Output:
 "UID        PID  PPID  C STIME TTY          TIME CMD\nroot      3217     1  1 19:25 ?        00:02:38 /usr/bin/kubelet --cloud-provider aws --config /etc/kubernetes/kubelet/kubelet-config.json --kubeconfig /var/lib/kubelet/kubeconfig --container-runtime docker --network-plugin cni --node-ip=192.168.69.155 --pod-infra-container-image=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/pause:3.1-eksbuild.1 --v=2 --node-labels=eks.amazonaws.com/sourceLaunchTemplateVersion=1,alpha.eksctl.io/cluster-name=eksworkshop-eksctl,alpha.eksctl.io/nodegroup-name=nodegroup,eks.amazonaws.com/nodegroup-image=ami-0b8ee6712a546f246,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=nodegroup,eks.amazonaws.com/sourceLaunchTemplateId=lt-04698ac31da975ca2\n"
I1006 22:25:12.354130   26126 check.go:299] Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json"
I1006 22:25:12.354151   26126 check.go:300] Output:
 "{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true,\n    \"CSIServiceAccountToken\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"376Mi\"\n  },\n  \"maxPods\": 11\n}\n"
I1006 22:25:12.354212   26126 check.go:221] Running 1 test_items
I1006 22:25:12.354223   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.354231   26126 test.go:245] Flag '--anonymous-auth' does not exist
I1006 22:25:12.354373   26126 test.go:169] In pathTestItem.findValue false
I1006 22:25:12.354386   26126 test.go:247] Path '{.authentication.anonymous.enabled}' exists
I1006 22:25:12.354391   26126 check.go:245] Used auditConfig
I1006 22:25:12.354399   26126 check.go:277] Returning from execute on tests: finalOutput &check.testOutput{testResult:true, flagFound:false, actualResult:"{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true,\n    \"CSIServiceAccountToken\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"376Mi\"\n  },\n  \"maxPods\": 11\n}", ExpectedResult:"'{.authentication.anonymous.enabled}' is equal to 'false'"}
I1006 22:25:12.354456   26126 check.go:184] Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json" TestResult: true State: "PASS"
I1006 22:25:12.354470   26126 check.go:110] -----   Running check 3.2.2   -----
I1006 22:25:12.359623   26126 check.go:299] Command: "/bin/ps -fC kubelet"
I1006 22:25:12.359639   26126 check.go:300] Output:
 "UID        PID  PPID  C STIME TTY          TIME CMD\nroot      3217     1  1 19:25 ?        00:02:38 /usr/bin/kubelet --cloud-provider aws --config /etc/kubernetes/kubelet/kubelet-config.json --kubeconfig /var/lib/kubelet/kubeconfig --container-runtime docker --network-plugin cni --node-ip=192.168.69.155 --pod-infra-container-image=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/pause:3.1-eksbuild.1 --v=2 --node-labels=eks.amazonaws.com/sourceLaunchTemplateVersion=1,alpha.eksctl.io/cluster-name=eksworkshop-eksctl,alpha.eksctl.io/nodegroup-name=nodegroup,eks.amazonaws.com/nodegroup-image=ami-0b8ee6712a546f246,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=nodegroup,eks.amazonaws.com/sourceLaunchTemplateId=lt-04698ac31da975ca2\n"
I1006 22:25:12.360713   26126 check.go:299] Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json"
I1006 22:25:12.360727   26126 check.go:300] Output:
 "{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true,\n    \"CSIServiceAccountToken\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"376Mi\"\n  },\n  \"maxPods\": 11\n}\n"
I1006 22:25:12.360793   26126 check.go:221] Running 1 test_items
I1006 22:25:12.360805   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.360844   26126 test.go:245] Flag '--authorization-mode' does not exist
I1006 22:25:12.360962   26126 test.go:169] In pathTestItem.findValue Webhook
I1006 22:25:12.360975   26126 test.go:247] Path '{.authorization.mode}' exists
I1006 22:25:12.361013   26126 check.go:245] Used auditConfig
I1006 22:25:12.361023   26126 check.go:277] Returning from execute on tests: finalOutput &check.testOutput{testResult:true, flagFound:false, actualResult:"{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true,\n    \"CSIServiceAccountToken\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"376Mi\"\n  },\n  \"maxPods\": 11\n}", ExpectedResult:"'{.authorization.mode}' does not have 'AlwaysAllow'"}
I1006 22:25:12.361117   26126 check.go:184] Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json" TestResult: true State: "PASS"
I1006 22:25:12.361129   26126 check.go:110] -----   Running check 3.2.3   -----
I1006 22:25:12.366418   26126 check.go:299] Command: "/bin/ps -fC kubelet"
I1006 22:25:12.366436   26126 check.go:300] Output:
 "UID        PID  PPID  C STIME TTY          TIME CMD\nroot      3217     1  1 19:25 ?        00:02:38 /usr/bin/kubelet --cloud-provider aws --config /etc/kubernetes/kubelet/kubelet-config.json --kubeconfig /var/lib/kubelet/kubeconfig --container-runtime docker --network-plugin cni --node-ip=192.168.69.155 --pod-infra-container-image=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/pause:3.1-eksbuild.1 --v=2 --node-labels=eks.amazonaws.com/sourceLaunchTemplateVersion=1,alpha.eksctl.io/cluster-name=eksworkshop-eksctl,alpha.eksctl.io/nodegroup-name=nodegroup,eks.amazonaws.com/nodegroup-image=ami-0b8ee6712a546f246,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=nodegroup,eks.amazonaws.com/sourceLaunchTemplateId=lt-04698ac31da975ca2\n"
I1006 22:25:12.367379   26126 check.go:299] Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json"
I1006 22:25:12.367394   26126 check.go:300] Output:
 "{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true,\n    \"CSIServiceAccountToken\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"376Mi\"\n  },\n  \"maxPods\": 11\n}\n"
I1006 22:25:12.367434   26126 check.go:221] Running 1 test_items
I1006 22:25:12.367447   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.367457   26126 test.go:245] Flag '--client-ca-file' does not exist
I1006 22:25:12.367591   26126 test.go:169] In pathTestItem.findValue /etc/kubernetes/pki/ca.crt
I1006 22:25:12.367600   26126 test.go:247] Path '{.authentication.x509.clientCAFile}' exists
I1006 22:25:12.367605   26126 check.go:245] Used auditConfig
I1006 22:25:12.367613   26126 check.go:277] Returning from execute on tests: finalOutput &check.testOutput{testResult:true, flagFound:false, actualResult:"{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true,\n    \"CSIServiceAccountToken\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"376Mi\"\n  },\n  \"maxPods\": 11\n}", ExpectedResult:"'{.authentication.x509.clientCAFile}' is present"}
I1006 22:25:12.367681   26126 check.go:184] Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json" TestResult: true State: "PASS"
I1006 22:25:12.367692   26126 check.go:110] -----   Running check 3.2.4   -----
I1006 22:25:12.372616   26126 check.go:299] Command: "/bin/ps -fC kubelet"
I1006 22:25:12.372631   26126 check.go:300] Output:
 "UID        PID  PPID  C STIME TTY          TIME CMD\nroot      3217     1  1 19:25 ?        00:02:38 /usr/bin/kubelet --cloud-provider aws --config /etc/kubernetes/kubelet/kubelet-config.json --kubeconfig /var/lib/kubelet/kubeconfig --container-runtime docker --network-plugin cni --node-ip=192.168.69.155 --pod-infra-container-image=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/pause:3.1-eksbuild.1 --v=2 --node-labels=eks.amazonaws.com/sourceLaunchTemplateVersion=1,alpha.eksctl.io/cluster-name=eksworkshop-eksctl,alpha.eksctl.io/nodegroup-name=nodegroup,eks.amazonaws.com/nodegroup-image=ami-0b8ee6712a546f246,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=nodegroup,eks.amazonaws.com/sourceLaunchTemplateId=lt-04698ac31da975ca2\n"
I1006 22:25:12.373556   26126 check.go:299] Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json"
I1006 22:25:12.373573   26126 check.go:300] Output:
 "{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true,\n    \"CSIServiceAccountToken\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"376Mi\"\n  },\n  \"maxPods\": 11\n}\n"
I1006 22:25:12.373638   26126 check.go:221] Running 1 test_items
I1006 22:25:12.373650   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.373658   26126 test.go:245] Flag '--read-only-port' does not exist
I1006 22:25:12.373791   26126 test.go:169] In pathTestItem.findValue 0
I1006 22:25:12.373804   26126 test.go:247] Path '{.readOnlyPort}' exists
I1006 22:25:12.373809   26126 check.go:245] Used auditConfig
I1006 22:25:12.373816   26126 check.go:277] Returning from execute on tests: finalOutput &check.testOutput{testResult:true, flagFound:false, actualResult:"{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true,\n    \"CSIServiceAccountToken\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"376Mi\"\n  },\n  \"maxPods\": 11\n}", ExpectedResult:"'{.readOnlyPort}' is equal to '0'"}
I1006 22:25:12.373872   26126 check.go:184] Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json" TestResult: true State: "PASS"
I1006 22:25:12.373883   26126 check.go:110] -----   Running check 3.2.5   -----
I1006 22:25:12.378812   26126 check.go:299] Command: "/bin/ps -fC kubelet"
I1006 22:25:12.378829   26126 check.go:300] Output:
 "UID        PID  PPID  C STIME TTY          TIME CMD\nroot      3217     1  1 19:25 ?        00:02:38 /usr/bin/kubelet --cloud-provider aws --config /etc/kubernetes/kubelet/kubelet-config.json --kubeconfig /var/lib/kubelet/kubeconfig --container-runtime docker --network-plugin cni --node-ip=192.168.69.155 --pod-infra-container-image=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/pause:3.1-eksbuild.1 --v=2 --node-labels=eks.amazonaws.com/sourceLaunchTemplateVersion=1,alpha.eksctl.io/cluster-name=eksworkshop-eksctl,alpha.eksctl.io/nodegroup-name=nodegroup,eks.amazonaws.com/nodegroup-image=ami-0b8ee6712a546f246,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=nodegroup,eks.amazonaws.com/sourceLaunchTemplateId=lt-04698ac31da975ca2\n"
I1006 22:25:12.379745   26126 check.go:299] Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json"
I1006 22:25:12.379760   26126 check.go:300] Output:
 "{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true,\n    \"CSIServiceAccountToken\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"376Mi\"\n  },\n  \"maxPods\": 11\n}\n"
I1006 22:25:12.379801   26126 check.go:221] Running 2 test_items
I1006 22:25:12.379828   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.379837   26126 test.go:245] Flag '--streaming-connection-idle-timeout' does not exist
I1006 22:25:12.379936   26126 test.go:169] In pathTestItem.findValue
I1006 22:25:12.379945   26126 test.go:247] Path '{.streamingConnectionIdleTimeout}' does not exist
I1006 22:25:12.379950   26126 check.go:245] Used auditConfig
I1006 22:25:12.379958   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.379990   26126 test.go:245] Flag '--streaming-connection-idle-timeout' does not exist
I1006 22:25:12.380052   26126 test.go:169] In pathTestItem.findValue
I1006 22:25:12.380084   26126 test.go:247] Path '{.streamingConnectionIdleTimeout}' does not exist
I1006 22:25:12.380088   26126 check.go:245] Used auditConfig
I1006 22:25:12.380096   26126 check.go:277] Returning from execute on tests: finalOutput &check.testOutput{testResult:true, flagFound:false, actualResult:"{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true,\n    \"CSIServiceAccountToken\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"376Mi\"\n  },\n  \"maxPods\": 11\n}", ExpectedResult:"'{.streamingConnectionIdleTimeout}' is present OR '{.streamingConnectionIdleTimeout}' is not present"}
I1006 22:25:12.380159   26126 check.go:184] Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json" TestResult: true State: "PASS"
I1006 22:25:12.380171   26126 check.go:110] -----   Running check 3.2.6   -----
I1006 22:25:12.385306   26126 check.go:299] Command: "/bin/ps -fC kubelet"
I1006 22:25:12.385323   26126 check.go:300] Output:
 "UID        PID  PPID  C STIME TTY          TIME CMD\nroot      3217     1  1 19:25 ?        00:02:38 /usr/bin/kubelet --cloud-provider aws --config /etc/kubernetes/kubelet/kubelet-config.json --kubeconfig /var/lib/kubelet/kubeconfig --container-runtime docker --network-plugin cni --node-ip=192.168.69.155 --pod-infra-container-image=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/pause:3.1-eksbuild.1 --v=2 --node-labels=eks.amazonaws.com/sourceLaunchTemplateVersion=1,alpha.eksctl.io/cluster-name=eksworkshop-eksctl,alpha.eksctl.io/nodegroup-name=nodegroup,eks.amazonaws.com/nodegroup-image=ami-0b8ee6712a546f246,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=nodegroup,eks.amazonaws.com/sourceLaunchTemplateId=lt-04698ac31da975ca2\n"
I1006 22:25:12.386349   26126 check.go:299] Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json"
I1006 22:25:12.386366   26126 check.go:300] Output:
 "{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true,\n    \"CSIServiceAccountToken\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"376Mi\"\n  },\n  \"maxPods\": 11\n}\n"
I1006 22:25:12.386426   26126 check.go:221] Running 1 test_items
I1006 22:25:12.386438   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.386446   26126 test.go:245] Flag '--protect-kernel-defaults' does not exist
I1006 22:25:12.386588   26126 test.go:169] In pathTestItem.findValue true
I1006 22:25:12.386601   26126 test.go:247] Path '{.protectKernelDefaults}' exists
I1006 22:25:12.386606   26126 check.go:245] Used auditConfig
I1006 22:25:12.386631   26126 check.go:277] Returning from execute on tests: finalOutput &check.testOutput{testResult:true, flagFound:false, actualResult:"{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true,\n    \"CSIServiceAccountToken\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"376Mi\"\n  },\n  \"maxPods\": 11\n}", ExpectedResult:"'{.protectKernelDefaults}' is equal to 'true'"}
I1006 22:25:12.386697   26126 check.go:184] Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json" TestResult: true State: "PASS"
I1006 22:25:12.386732   26126 check.go:110] -----   Running check 3.2.7   -----
I1006 22:25:12.392012   26126 check.go:299] Command: "/bin/ps -fC kubelet"
I1006 22:25:12.392027   26126 check.go:300] Output:
 "UID        PID  PPID  C STIME TTY          TIME CMD\nroot      3217     1  1 19:25 ?        00:02:38 /usr/bin/kubelet --cloud-provider aws --config /etc/kubernetes/kubelet/kubelet-config.json --kubeconfig /var/lib/kubelet/kubeconfig --container-runtime docker --network-plugin cni --node-ip=192.168.69.155 --pod-infra-container-image=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/pause:3.1-eksbuild.1 --v=2 --node-labels=eks.amazonaws.com/sourceLaunchTemplateVersion=1,alpha.eksctl.io/cluster-name=eksworkshop-eksctl,alpha.eksctl.io/nodegroup-name=nodegroup,eks.amazonaws.com/nodegroup-image=ami-0b8ee6712a546f246,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=nodegroup,eks.amazonaws.com/sourceLaunchTemplateId=lt-04698ac31da975ca2\n"
I1006 22:25:12.392992   26126 check.go:299] Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json"
I1006 22:25:12.393007   26126 check.go:300] Output:
 "{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true,\n    \"CSIServiceAccountToken\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"376Mi\"\n  },\n  \"maxPods\": 11\n}\n"
I1006 22:25:12.393069   26126 check.go:221] Running 2 test_items
I1006 22:25:12.393080   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.393087   26126 test.go:245] Flag '--make-iptables-util-chains' does not exist
I1006 22:25:12.393213   26126 test.go:169] In pathTestItem.findValue
I1006 22:25:12.393224   26126 test.go:247] Path '{.makeIPTablesUtilChains}' does not exist
I1006 22:25:12.393242   26126 check.go:245] Used auditConfig
I1006 22:25:12.393258   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.393267   26126 test.go:245] Flag '--make-iptables-util-chains' does not exist
I1006 22:25:12.393344   26126 test.go:169] In pathTestItem.findValue
I1006 22:25:12.393352   26126 test.go:247] Path '{.makeIPTablesUtilChains}' does not exist
I1006 22:25:12.393357   26126 check.go:245] Used auditConfig
I1006 22:25:12.393364   26126 check.go:277] Returning from execute on tests: finalOutput &check.testOutput{testResult:true, flagFound:false, actualResult:"{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true,\n    \"CSIServiceAccountToken\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"376Mi\"\n  },\n  \"maxPods\": 11\n}", ExpectedResult:"'{.makeIPTablesUtilChains}' is present OR '{.makeIPTablesUtilChains}' is not present"}
I1006 22:25:12.393427   26126 check.go:184] Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json" TestResult: true State: "PASS"
I1006 22:25:12.393459   26126 check.go:110] -----   Running check 3.2.8   -----
I1006 22:25:12.398498   26126 check.go:299] Command: "/bin/ps -fC kubelet"
I1006 22:25:12.398514   26126 check.go:300] Output:
 "UID        PID  PPID  C STIME TTY          TIME CMD\nroot      3217     1  1 19:25 ?        00:02:38 /usr/bin/kubelet --cloud-provider aws --config /etc/kubernetes/kubelet/kubelet-config.json --kubeconfig /var/lib/kubelet/kubeconfig --container-runtime docker --network-plugin cni --node-ip=192.168.69.155 --pod-infra-container-image=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/pause:3.1-eksbuild.1 --v=2 --node-labels=eks.amazonaws.com/sourceLaunchTemplateVersion=1,alpha.eksctl.io/cluster-name=eksworkshop-eksctl,alpha.eksctl.io/nodegroup-name=nodegroup,eks.amazonaws.com/nodegroup-image=ami-0b8ee6712a546f246,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=nodegroup,eks.amazonaws.com/sourceLaunchTemplateId=lt-04698ac31da975ca2\n"
I1006 22:25:12.398558   26126 check.go:221] Running 1 test_items
I1006 22:25:12.398582   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.398589   26126 test.go:245] Flag '--hostname-override' does not exist
I1006 22:25:12.398593   26126 check.go:245] Used auditCommand
I1006 22:25:12.398600   26126 check.go:277] Returning from execute on tests: finalOutput &check.testOutput{testResult:true, flagFound:false, actualResult:"UID        PID  PPID  C STIME TTY          TIME CMD\nroot      3217     1  1 19:25 ?        00:02:38 /usr/bin/kubelet --cloud-provider aws --config /etc/kubernetes/kubelet/kubelet-config.json --kubeconfig /var/lib/kubelet/kubeconfig --container-runtime docker --network-plugin cni --node-ip=192.168.69.155 --pod-infra-container-image=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/pause:3.1-eksbuild.1 --v=2 --node-labels=eks.amazonaws.com/sourceLaunchTemplateVersion=1,alpha.eksctl.io/cluster-name=eksworkshop-eksctl,alpha.eksctl.io/nodegroup-name=nodegroup,eks.amazonaws.com/nodegroup-image=ami-0b8ee6712a546f246,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=nodegroup,eks.amazonaws.com/sourceLaunchTemplateId=lt-04698ac31da975ca2", ExpectedResult:"'--hostname-override' is not present"}
I1006 22:25:12.398677   26126 check.go:184] Command: "" TestResult: true State: "PASS"
I1006 22:25:12.398687   26126 check.go:110] -----   Running check 3.2.9   -----
I1006 22:25:12.403565   26126 check.go:299] Command: "/bin/ps -fC kubelet"
I1006 22:25:12.403581   26126 check.go:300] Output:
 "UID        PID  PPID  C STIME TTY          TIME CMD\nroot      3217     1  1 19:25 ?        00:02:38 /usr/bin/kubelet --cloud-provider aws --config /etc/kubernetes/kubelet/kubelet-config.json --kubeconfig /var/lib/kubelet/kubeconfig --container-runtime docker --network-plugin cni --node-ip=192.168.69.155 --pod-infra-container-image=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/pause:3.1-eksbuild.1 --v=2 --node-labels=eks.amazonaws.com/sourceLaunchTemplateVersion=1,alpha.eksctl.io/cluster-name=eksworkshop-eksctl,alpha.eksctl.io/nodegroup-name=nodegroup,eks.amazonaws.com/nodegroup-image=ami-0b8ee6712a546f246,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=nodegroup,eks.amazonaws.com/sourceLaunchTemplateId=lt-04698ac31da975ca2\n"
I1006 22:25:12.404461   26126 check.go:299] Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json"
I1006 22:25:12.404476   26126 check.go:300] Output:
 "{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true,\n    \"CSIServiceAccountToken\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"376Mi\"\n  },\n  \"maxPods\": 11\n}\n"
I1006 22:25:12.404701   26126 check.go:221] Running 1 test_items
I1006 22:25:12.404715   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.404729   26126 test.go:245] Flag '--event-qps' does not exist
I1006 22:25:12.404840   26126 test.go:169] In pathTestItem.findValue
I1006 22:25:12.404852   26126 test.go:247] Path '{.eventRecordQPS}' does not exist
I1006 22:25:12.404857   26126 check.go:245] Used auditConfig
I1006 22:25:12.404865   26126 check.go:277] Returning from execute on tests: finalOutput &check.testOutput{testResult:false, flagFound:false, actualResult:"{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true,\n    \"CSIServiceAccountToken\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"376Mi\"\n  },\n  \"maxPods\": 11\n}", ExpectedResult:"'{.eventRecordQPS}' is present"}
I1006 22:25:12.404939   26126 check.go:184] Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json" TestResult: false State: "WARN"
I1006 22:25:12.404985   26126 check.go:110] -----   Running check 3.2.10   -----
I1006 22:25:12.409747   26126 check.go:299] Command: "/bin/ps -fC kubelet"
I1006 22:25:12.409764   26126 check.go:300] Output:
 "UID        PID  PPID  C STIME TTY          TIME CMD\nroot      3217     1  1 19:25 ?        00:02:38 /usr/bin/kubelet --cloud-provider aws --config /etc/kubernetes/kubelet/kubelet-config.json --kubeconfig /var/lib/kubelet/kubeconfig --container-runtime docker --network-plugin cni --node-ip=192.168.69.155 --pod-infra-container-image=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/pause:3.1-eksbuild.1 --v=2 --node-labels=eks.amazonaws.com/sourceLaunchTemplateVersion=1,alpha.eksctl.io/cluster-name=eksworkshop-eksctl,alpha.eksctl.io/nodegroup-name=nodegroup,eks.amazonaws.com/nodegroup-image=ami-0b8ee6712a546f246,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=nodegroup,eks.amazonaws.com/sourceLaunchTemplateId=lt-04698ac31da975ca2\n"
I1006 22:25:12.410740   26126 check.go:299] Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json"
I1006 22:25:12.410759   26126 check.go:300] Output:
 "{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true,\n    \"CSIServiceAccountToken\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"376Mi\"\n  },\n  \"maxPods\": 11\n}\n"
I1006 22:25:12.410877   26126 check.go:221] Running 2 test_items
I1006 22:25:12.410913   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.410922   26126 test.go:245] Flag '--rotate-certificates' does not exist
I1006 22:25:12.411072   26126 test.go:169] In pathTestItem.findValue
I1006 22:25:12.411083   26126 test.go:247] Path '{.rotateCertificates}' does not exist
I1006 22:25:12.411099   26126 check.go:245] Used auditConfig
I1006 22:25:12.411108   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.411115   26126 test.go:245] Flag '--rotate-certificates' does not exist
I1006 22:25:12.411202   26126 test.go:169] In pathTestItem.findValue
I1006 22:25:12.411216   26126 test.go:247] Path '{.rotateCertificates}' does not exist
I1006 22:25:12.411220   26126 check.go:245] Used auditConfig
I1006 22:25:12.411228   26126 check.go:277] Returning from execute on tests: finalOutput &check.testOutput{testResult:true, flagFound:false, actualResult:"{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true,\n    \"CSIServiceAccountToken\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"376Mi\"\n  },\n  \"maxPods\": 11\n}", ExpectedResult:"'{.rotateCertificates}' is present OR '{.rotateCertificates}' is not present"}
I1006 22:25:12.411287   26126 check.go:184] Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json" TestResult: true State: "PASS"
I1006 22:25:12.411321   26126 check.go:110] -----   Running check 3.2.11   -----
I1006 22:25:12.416650   26126 check.go:299] Command: "/bin/ps -fC kubelet"
I1006 22:25:12.416667   26126 check.go:300] Output:
 "UID        PID  PPID  C STIME TTY          TIME CMD\nroot      3217     1  1 19:25 ?        00:02:38 /usr/bin/kubelet --cloud-provider aws --config /etc/kubernetes/kubelet/kubelet-config.json --kubeconfig /var/lib/kubelet/kubeconfig --container-runtime docker --network-plugin cni --node-ip=192.168.69.155 --pod-infra-container-image=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/pause:3.1-eksbuild.1 --v=2 --node-labels=eks.amazonaws.com/sourceLaunchTemplateVersion=1,alpha.eksctl.io/cluster-name=eksworkshop-eksctl,alpha.eksctl.io/nodegroup-name=nodegroup,eks.amazonaws.com/nodegroup-image=ami-0b8ee6712a546f246,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=nodegroup,eks.amazonaws.com/sourceLaunchTemplateId=lt-04698ac31da975ca2\n"
I1006 22:25:12.417590   26126 check.go:299] Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json"
I1006 22:25:12.417605   26126 check.go:300] Output:
 "{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true,\n    \"CSIServiceAccountToken\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"376Mi\"\n  },\n  \"maxPods\": 11\n}\n"
I1006 22:25:12.417666   26126 check.go:221] Running 1 test_items
I1006 22:25:12.417676   26126 test.go:151] In flagTestItem.findValue
I1006 22:25:12.417685   26126 test.go:245] Flag 'RotateKubeletServerCertificate' does not exist
I1006 22:25:12.417817   26126 test.go:169] In pathTestItem.findValue true
I1006 22:25:12.417830   26126 test.go:247] Path '{.featureGates.RotateKubeletServerCertificate}' exists
I1006 22:25:12.417849   26126 check.go:245] Used auditConfig
I1006 22:25:12.417858   26126 check.go:277] Returning from execute on tests: finalOutput &check.testOutput{testResult:true, flagFound:false, actualResult:"{\n  \"kind\": \"KubeletConfiguration\",\n  \"apiVersion\": \"kubelet.config.k8s.io/v1beta1\",\n  \"address\": \"0.0.0.0\",\n  \"authentication\": {\n    \"anonymous\": {\n      \"enabled\": false\n    },\n    \"webhook\": {\n      \"cacheTTL\": \"2m0s\",\n      \"enabled\": true\n    },\n    \"x509\": {\n      \"clientCAFile\": \"/etc/kubernetes/pki/ca.crt\"\n    }\n  },\n  \"authorization\": {\n    \"mode\": \"Webhook\",\n    \"webhook\": {\n      \"cacheAuthorizedTTL\": \"5m0s\",\n      \"cacheUnauthorizedTTL\": \"30s\"\n    }\n  },\n  \"clusterDomain\": \"cluster.local\",\n  \"hairpinMode\": \"hairpin-veth\",\n  \"readOnlyPort\": 0,\n  \"cgroupDriver\": \"cgroupfs\",\n  \"cgroupRoot\": \"/\",\n  \"featureGates\": {\n    \"RotateKubeletServerCertificate\": true,\n    \"CSIServiceAccountToken\": true\n  },\n  \"protectKernelDefaults\": true,\n  \"serializeImagePulls\": false,\n  \"serverTLSBootstrap\": true,\n  \"tlsCipherSuites\": [\n    \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\n    \"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305\",\n    \"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_256_GCM_SHA384\",\n    \"TLS_RSA_WITH_AES_128_GCM_SHA256\"\n  ],\n  \"clusterDNS\": [\n    \"10.100.0.10\"\n  ],\n  \"evictionHard\": {\n    \"memory.available\": \"100Mi\",\n    \"nodefs.available\": \"10%\",\n    \"nodefs.inodesFree\": \"5%\"\n  },\n  \"kubeReserved\": {\n    \"cpu\": \"70m\",\n    \"ephemeral-storage\": \"1Gi\",\n    \"memory\": \"376Mi\"\n  },\n  \"maxPods\": 11\n}", ExpectedResult:"'{.featureGates.RotateKubeletServerCertificate}' is equal to 'true'"}
I1006 22:25:12.417923   26126 check.go:184] Command: "/bin/cat /etc/kubernetes/kubelet/kubelet-config.json" TestResult: true State: "PASS"
I1006 22:25:12.417987   26126 root.go:119] == Running policies checks ==
I1006 22:25:12.417998   26126 util.go:117] Looking for config specific CIS version "eks-1.0"
I1006 22:25:12.418006   26126 util.go:121] Looking for file: cfg/eks-1.0/policies.yaml
I1006 22:25:12.418138   26126 common.go:274] Using config file: cfg/eks-1.0/config.yaml
I1006 22:25:12.418222   26126 common.go:79] Using test file: cfg/eks-1.0/policies.yaml
I1006 22:25:12.418782   26126 check.go:110] -----   Running check 4.1.1   -----
I1006 22:25:12.418794   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418800   26126 check.go:110] -----   Running check 4.1.2   -----
I1006 22:25:12.418809   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418813   26126 check.go:110] -----   Running check 4.1.3   -----
I1006 22:25:12.418818   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418821   26126 check.go:110] -----   Running check 4.1.4   -----
I1006 22:25:12.418826   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418830   26126 check.go:110] -----   Running check 4.1.5   -----
I1006 22:25:12.418835   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418839   26126 check.go:110] -----   Running check 4.1.6   -----
I1006 22:25:12.418843   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418847   26126 check.go:110] -----   Running check 4.2.1   -----
I1006 22:25:12.418852   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418856   26126 check.go:110] -----   Running check 4.2.2   -----
I1006 22:25:12.418861   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418865   26126 check.go:110] -----   Running check 4.2.3   -----
I1006 22:25:12.418870   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418874   26126 check.go:110] -----   Running check 4.2.4   -----
I1006 22:25:12.418879   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418883   26126 check.go:110] -----   Running check 4.2.5   -----
I1006 22:25:12.418887   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418890   26126 check.go:110] -----   Running check 4.2.6   -----
I1006 22:25:12.418895   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418898   26126 check.go:110] -----   Running check 4.2.7   -----
I1006 22:25:12.418903   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418907   26126 check.go:110] -----   Running check 4.2.8   -----
I1006 22:25:12.418912   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418916   26126 check.go:110] -----   Running check 4.2.9   -----
I1006 22:25:12.418920   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418925   26126 check.go:110] -----   Running check 4.3.1   -----
I1006 22:25:12.418929   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418934   26126 check.go:110] -----   Running check 4.3.2   -----
I1006 22:25:12.418939   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418943   26126 check.go:110] -----   Running check 4.4.1   -----
I1006 22:25:12.418948   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418952   26126 check.go:110] -----   Running check 4.4.2   -----
I1006 22:25:12.418957   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418961   26126 check.go:110] -----   Running check 4.5.1   -----
I1006 22:25:12.418965   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418969   26126 check.go:110] -----   Running check 4.6.1   -----
I1006 22:25:12.418973   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418982   26126 check.go:110] -----   Running check 4.6.2   -----
I1006 22:25:12.418986   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418989   26126 check.go:110] -----   Running check 4.6.3   -----
I1006 22:25:12.418993   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.418997   26126 check.go:110] -----   Running check 4.6.4   -----
I1006 22:25:12.419000   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.419033   26126 root.go:132] == Running managed services checks ==
I1006 22:25:12.419040   26126 util.go:117] Looking for config specific CIS version "eks-1.0"
I1006 22:25:12.419046   26126 util.go:121] Looking for file: cfg/eks-1.0/managedservices.yaml
I1006 22:25:12.419140   26126 common.go:274] Using config file: cfg/eks-1.0/config.yaml
I1006 22:25:12.419169   26126 common.go:79] Using test file: cfg/eks-1.0/managedservices.yaml
I1006 22:25:12.419486   26126 check.go:110] -----   Running check 5.1.1   -----
I1006 22:25:12.419499   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.419503   26126 check.go:110] -----   Running check 5.1.2   -----
I1006 22:25:12.419508   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.419512   26126 check.go:110] -----   Running check 5.1.3   -----
I1006 22:25:12.419517   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.419520   26126 check.go:110] -----   Running check 5.1.4   -----
I1006 22:25:12.419524   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.419528   26126 check.go:110] -----   Running check 5.2.1   -----
I1006 22:25:12.419533   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.419537   26126 check.go:110] -----   Running check 5.3.1   -----
I1006 22:25:12.419542   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.419547   26126 check.go:110] -----   Running check 5.4.1   -----
I1006 22:25:12.419551   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.419556   26126 check.go:110] -----   Running check 5.4.2   -----
I1006 22:25:12.419560   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.419565   26126 check.go:110] -----   Running check 5.4.3   -----
I1006 22:25:12.419569   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.419573   26126 check.go:110] -----   Running check 5.4.4   -----
I1006 22:25:12.419578   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.419582   26126 check.go:110] -----   Running check 5.4.5   -----
I1006 22:25:12.419586   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.419590   26126 check.go:110] -----   Running check 5.5.1   -----
I1006 22:25:12.419594   26126 check.go:133] Test marked as a manual test
I1006 22:25:12.419598   26126 check.go:110] -----   Running check 5.6.1   -----
I1006 22:25:12.419609   26126 check.go:133] Test marked as a manual test
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

== Remediations node ==
3.2.9 If using a Kubelet config file, edit the file to set eventRecordQPS: to an appropriate level.
If using command line arguments, edit the kubelet service file
/etc/systemd/system/kubelet.service on each worker node and
set the below parameter in KUBELET_SYSTEM_PODS_ARGS variable.
Based on your system, restart the kubelet service. For example:
systemctl daemon-reload
systemctl restart kubelet.service


== Summary node ==
14 checks PASS
0 checks FAIL
1 checks WARN
0 checks INFO

[INFO] 4 Policies
[INFO] 4.1 RBAC and Service Accounts
[WARN] 4.1.1 Ensure that the cluster-admin role is only used where required (Not Scored)
[WARN] 4.1.2 Minimize access to secrets (Not Scored)
[WARN] 4.1.3 Minimize wildcard use in Roles and ClusterRoles (Not Scored)
[WARN] 4.1.4 Minimize access to create pods (Not Scored)
[WARN] 4.1.5 Ensure that default service accounts are not actively used. (Not Scored)
[WARN] 4.1.6 Ensure that Service Account Tokens are only mounted where necessary (Not Scored)
[INFO] 4.2 Pod Security Policies
[WARN] 4.2.1 Minimize the admission of privileged containers (Not Scored)
[WARN] 4.2.2 Minimize the admission of containers wishing to share the host process ID namespace (Not Scored)
[WARN] 4.2.3 Minimize the admission of containers wishing to share the host IPC namespace (Not Scored)
[WARN] 4.2.4 Minimize the admission of containers wishing to share the host network namespace (Not Scored)
[WARN] 4.2.5 Minimize the admission of containers with allowPrivilegeEscalation (Not Scored)
[WARN] 4.2.6 Minimize the admission of root containers (Not Scored)
[WARN] 4.2.7 Minimize the admission of containers with the NET_RAW capability (Not Scored)
[WARN] 4.2.8 Minimize the admission of containers with added capabilities (Not Scored)
[WARN] 4.2.9 Minimize the admission of containers with capabilities assigned (Not Scored)
[INFO] 4.3 CNI Plugin
[WARN] 4.3.1 Ensure that the latest CNI version is used (Not Scored)
[WARN] 4.3.2 Ensure that all Namespaces have Network Policies defined (Not Scored)
[INFO] 4.4 Secrets Management
[WARN] 4.4.1 Prefer using secrets as files over secrets as environment variables (Not Scored)
[WARN] 4.4.2 Consider external secret storage (Not Scored)
[INFO] 4.5 Extensible Admission Control
[WARN] 4.5.1 Configure Image Provenance using ImagePolicyWebhook admission controller (Not Scored)
[INFO] 4.6 General Policies
[WARN] 4.6.1 Create administrative boundaries between resources using namespaces (Not Scored)
[WARN] 4.6.2 Ensure that the seccomp profile is set to docker/default in your pod definitions (Not Scored)
[WARN] 4.6.3 Apply Security Context to Your Pods and Containers (Not Scored)
[WARN] 4.6.4 The default namespace should not be used (Not Scored)

== Remediations policies ==
4.1.1 Identify all clusterrolebindings to the cluster-admin role. Check if they are used and
if they need this role or if they could use a role with fewer privileges.
Where possible, first bind users to a lower privileged role and then remove the
clusterrolebinding to the cluster-admin role :
kubectl delete clusterrolebinding [name]

4.1.2 Where possible, remove get, list and watch access to secret objects in the cluster.

4.1.3 Where possible replace any use of wildcards in clusterroles and roles with specific
objects or actions.

4.1.4
4.1.5 Create explicit service accounts wherever a Kubernetes workload requires specific access
to the Kubernetes API server.
Modify the configuration of each default service account to include this value
automountServiceAccountToken: false

4.1.6 Modify the definition of pods and service accounts which do not need to mount service
account tokens to disable it.

4.2.1 Create a PSP as described in the Kubernetes documentation, ensuring that
the .spec.privileged field is omitted or set to false.

4.2.2 Create a PSP as described in the Kubernetes documentation, ensuring that the
.spec.hostPID field is omitted or set to false.

4.2.3 Create a PSP as described in the Kubernetes documentation, ensuring that the
.spec.hostIPC field is omitted or set to false.

4.2.4 Create a PSP as described in the Kubernetes documentation, ensuring that the
.spec.hostNetwork field is omitted or set to false.

4.2.5 Create a PSP as described in the Kubernetes documentation, ensuring that the
.spec.allowPrivilegeEscalation field is omitted or set to false.

4.2.6 Create a PSP as described in the Kubernetes documentation, ensuring that the
.spec.runAsUser.rule is set to either MustRunAsNonRoot or MustRunAs with the range of
UIDs not including 0.

4.2.7 Create a PSP as described in the Kubernetes documentation, ensuring that the
.spec.requiredDropCapabilities is set to include either NET_RAW or ALL.

4.2.8 Ensure that allowedCapabilities is not present in PSPs for the cluster unless
it is set to an empty array.

4.2.9 Review the use of capabilities in applications running on your cluster. Where a namespace
contains applications which do not require any Linux capabities to operate consider adding
a PSP which forbids the admission of containers which do not drop all capabilities.

4.3.1 Review the documentation of AWS CNI plugin, and ensure latest CNI version is used.

4.3.2 Follow the documentation and create NetworkPolicy objects as you need them.

4.4.1 If possible, rewrite application code to read secrets from mounted secret files, rather than
from environment variables.

4.4.2 Refer to the secrets management options offered by your cloud provider or a third-party
secrets management solution.

4.5.1 Follow the Kubernetes documentation and setup image provenance.

4.6.1 Follow the documentation and create namespaces for objects in your deployment as you need
them.

4.6.2 Seccomp is an alpha feature currently. By default, all alpha features are disabled. So, you
would need to enable alpha features in the apiserver by passing "--feature-
gates=AllAlpha=true" argument.
Edit the /etc/kubernetes/apiserver file on the master node and set the KUBE_API_ARGS
parameter to "--feature-gates=AllAlpha=true"
KUBE_API_ARGS="--feature-gates=AllAlpha=true"
Based on your system, restart the kube-apiserver service. For example:
systemctl restart kube-apiserver.service
Use annotations to enable the docker/default seccomp profile in your pod definitions. An
example is as below:
apiVersion: v1
kind: Pod
metadata:
  name: trustworthy-pod
  annotations:
    seccomp.security.alpha.kubernetes.io/pod: docker/default
spec:
  containers:
    - name: trustworthy-container
      image: sotrustworthy:latest

4.6.3 Follow the Kubernetes documentation and apply security contexts to your pods. For a
suggested list of security contexts, you may refer to the CIS Security Benchmark for Docker
Containers.

4.6.4 Ensure that namespaces are created to allow for appropriate segregation of Kubernetes
resources and that all new resources are created in a specific namespace.


== Summary policies ==
0 checks PASS
0 checks FAIL
24 checks WARN
0 checks INFO

[INFO] 5 Managed Services
[INFO] 5.1 Image Registry and Image Scanning
[WARN] 5.1.1 Ensure Image Vulnerability Scanning using Amazon ECR image scanning or a third-party provider (Not Scored)
[WARN] 5.1.2 Minimize user access to Amazon ECR (Not Scored)
[WARN] 5.1.3 Minimize cluster access to read-only for Amazon ECR (Not Scored)
[WARN] 5.1.4 Minimize Container Registries to only those approved (Not Scored)
[INFO] 5.2 Identity and Access Management (IAM)
[WARN] 5.2.1 Prefer using dedicated Amazon EKS Service Accounts (Not Scored)
[INFO] 5.3 AWS Key Management Service (AWS KMS)
[WARN] 5.3.1 Ensure Kubernetes Secrets are encrypted using Customer Master Keys (CMKs) managed in AWS KMS (Not Scored)
[INFO] 5.4 Cluster Networking
[WARN] 5.4.1 Restrict Access to the Control Plane Endpoint (Not Scored)
[WARN] 5.4.2 Ensure clusters are created with Private Endpoint Enabled and Public Access Disabled (Not Scored)
[WARN] 5.4.3 Ensure clusters are created with Private Nodes (Not Scored)
[WARN] 5.4.4 Ensure Network Policy is Enabled and set as appropriate (Not Scored)
[WARN] 5.4.5 Encrypt traffic to HTTPS load balancers with TLS certificates (Not Scored)
[INFO] 5.5 Authentication and Authorization
[WARN] 5.5.1 Manage Kubernetes RBAC users with AWS IAM Authenticator for Kubernetes (Not Scored)
[INFO] 5.6 Other Cluster Configurations
[WARN] 5.6.1 Consider Fargate for running untrusted workloads (Not Scored)

== Remediations managedservices ==
5.1.1
5.1.2
5.1.3
5.1.4
5.2.1
5.3.1
5.4.1
5.4.2
5.4.3
5.4.4
5.4.5
5.5.1
5.6.1

== Summary managedservices ==
0 checks PASS
0 checks FAIL
13 checks WARN
0 checks INFO

== Summary total ==
14 checks PASS
0 checks FAIL
38 checks WARN
0 checks INFO
```

{{% notice note %}}
As mentioned in the earlier example, `kube-bench` is an evolving tool, and your output may differ from above based on improvements to the tool and/or the CIS benchmark at the time that you run the tool.
{{% /notice %}}

## Cleanup

- Delete the resources

```
kubectl delete -f job-debug-eks.yaml
rm -f job-debug-eks.yaml
```


