---
title: "Configure Kubernetes RBAC"
date: 2020-04-05T18:00:00-00:00
draft: false
weight: 30
---

You can refere to [intro to RBAC](/beginner/090_rbac/) module to understand the basic of Kubernetes RBAC.

#### Create a namespace `integration` and for `development`

* **development** namespace will be accessible for IAM users from **k8sDev** group
* **integration** namespace will be accessible for IAM users from **k8sInteg** group

```
kubectl create namespace integration
kubectl create namespace development
```

#### Create kubernetes role and rolebinding for kubernetes user dev-user in development namespace



We create a role in the development namespace for full access with the kubernetes user **dev-user**

```
cat << EOF | kubectl apply -f - -n development
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: dev-role
rules:
  - apiGroups:
      - ""
      - "apps"
      - "batch"
      - "extensions"
    resources:
      - "configmaps"
      - "cronjobs"
      - "deployments"
      - "events"
      - "ingresses"
      - "jobs"
      - "pods"
      - "pods/attach"
      - "pods/exec"
      - "pods/log"
      - "pods/portforward"
      - "secrets"
      - "services"
    verbs:
      - "create"
      - "delete"
      - "describe"
      - "get"
      - "list"
      - "patch"
      - "update"
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: dev-role-binding
subjects:
- kind: User
  name: dev-user
roleRef:
  kind: Role
  name: dev-role
  apiGroup: rbac.authorization.k8s.io
EOF
```

The role we define will give full access to everything in that namespace. It is a Role, and not a ClusterRole, so it is going to be applied only in the **integration** namespace.

> feel free to adapt to any namespace you prefer.

#### Create kubernetes role and rolebinding for kubernetes user integ-user in integration namespace

We create a role in the development namespace for full access with the kubernetes user **integ-user**


```
cat << EOF | kubectl apply -f - -n integration
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: integ-role
rules:
  - apiGroups:
      - ""
      - "apps"
      - "batch"
      - "extensions"
    resources:
      - "configmaps"
      - "cronjobs"
      - "deployments"
      - "events"
      - "ingresses"
      - "jobs"
      - "pods"
      - "pods/attach"
      - "pods/exec"
      - "pods/log"
      - "pods/portforward"
      - "secrets"
      - "services"
    verbs:
      - "create"
      - "delete"
      - "describe"
      - "get"
      - "list"
      - "patch"
      - "update"
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: dev-role-binding
subjects:
- kind: User
  name: integ-user
roleRef:
  kind: Role
  name: integ-role
  apiGroup: rbac.authorization.k8s.io
EOF
```

The role we define will give full access to everything in that namespace. It is a Role, and not a ClusterRole, so it is going to be applied only in the **integration** namespace.


