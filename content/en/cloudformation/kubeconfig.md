---
title: "Create KubeConfig File"
date: 2018-08-07T10:09:31-07:00
weight: 50
draft: true
---

Our KubeConfig file will need to know specific info about our EKS cluster. We
can gather that info and add it to our environment before building the file:
```
export EKS_ENDPOINT=$(aws eks describe-cluster --name eksworkshop-cf  --query cluster.[endpoint] --output=text)
export EKS_CA_DATA=$(aws eks describe-cluster --name eksworkshop-cf  --query cluster.[certificateAuthority.data] --output text)
```

Let’s confirm the variables are now set in our environment:
```
echo EKS_ENDPOINT=${EKS_ENDPOINT}
echo EKS_CA_DATA=${EKS_CA_DATA}
```

Now we can create the KubeConfig file:
```
mkdir ${HOME}/.kube

cat <<EoF > ${HOME}/.kube/config-eksworkshop-cf
  apiVersion: v1
  clusters:
  - cluster:
      server: ${EKS_ENDPOINT}
      certificate-authority-data: ${EKS_CA_DATA}
    name: kubernetes
  contexts:
  - context:
      cluster: kubernetes
      user: aws
    name: aws
  current-context: aws
  kind: Config
  preferences: {}
  users:
  - name: aws
    user:
      exec:
        apiVersion: client.authentication.k8s.io/v1alpha1
        command: heptio-authenticator-aws
        args:
          - "token"
          - "-i"
          - "eksworkshop-cf"
EoF
```

We now need to add this new config to the KubeCtl Config list:
```
export KUBECONFIG=${HOME}/.kube/config-eksworkshop-cf
echo "export KUBECONFIG=${KUBECONFIG}" >> ${HOME}/.bashrc
```

Let’s confirm that your KubeConfig is available:
```
kubectl config view
```

Let’s confirm that you can communicate with the Kubernetes API for your EKS cluster
```
kubectl get svc
```
