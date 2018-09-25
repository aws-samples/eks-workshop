---
title: "Deploy the AWS Service Operator"
date: 2018-08-07T08:30:11-07:00
weight: 10
draft: true
---

Before we build our manifest, we need to gather our account number and region to use in the
template:
```
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)

```

Copy and paste this manifest so that we can `kubectl apply` it.

```
cat <<EoF > ~/environment/aws-operator.yaml
---
kind: Namespace
apiVersion: v1
metadata:
  name: aws-operator
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: aws-operator
  namespace: aws-operator
data:
  accountID: "${ACCOUNT_ID}"
  clusterName: "eksworkshop-eksctl"
  region: "${AWS_REGION}"
  bucketName: ""
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: aws-operator
rules:
- apiGroups:
  - ""
  resources:
  - secrets
  - pods
  - configmaps
  - services
  verbs:
  - get
  - list
  - watch
  - create
  - delete
  - update
- apiGroups:
  - extensions
  resources:
  - thirdpartyresources
  verbs:
  - get
  - list
  - watch
  - create
  - delete
  - update
- apiGroups:
  - apiextensions.k8s.io
  resources:
  - customresourcedefinitions
  verbs:
  - get
  - list
  - watch
  - create
  - delete
- apiGroups:
  - operator.aws
  resources:
  - "*"
  verbs:
  - "*"
---
kind: ServiceAccount
apiVersion: v1
metadata:
  name: aws-operator
  namespace: aws-operator
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: aws-operator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: aws-operator
subjects:
- kind: ServiceAccount
  name: aws-operator
  namespace: aws-operator
---
kind: Deployment
apiVersion: apps/v1beta1
metadata:
  name: aws-operator
  namespace: aws-operator
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: aws-operator
    spec:
      serviceAccountName: aws-operator
      containers:
      - name: aws-operator
        image: christopherhein/test-operator:v0.0.1-alpha4
        imagePullPolicy: Always
        env:
        - name: clusterName
          valueFrom:
            configMapKeyRef:
              name: aws-operator
              key: clusterName
        - name: region
          valueFrom:
            configMapKeyRef:
              name: aws-operator
              key: region
        - name: bucketName
          valueFrom:
            configMapKeyRef:
              name: aws-operator
              key: bucketName
        - name: accountID
          valueFrom:
            configMapKeyRef:
              name: aws-operator
              key: accountID
        args:
          - server
          - --cluster-name=\$(clusterName)
          - --region=\$(region)
          - --bucket=\$(bucketName)
          - --account-id=\$(accountID)
EoF
```
Next apply the config:
```
kubectl apply -f ~/environment/aws-operator.yaml
```
