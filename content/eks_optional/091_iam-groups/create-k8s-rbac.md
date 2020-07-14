---
title: "Configure Kubernetes RBAC"
date: 2020-04-05T18:00:00-00:00
draft: false
weight: 30
---

You can refer to [intro to RBAC](/beginner/090_rbac/) module to understand the basic of Kubernetes RBAC.

#### Create kubernetes namespaces

* **development** namespace will be accessible for IAM users from **k8sDev** group
* **integration** namespace will be accessible for IAM users from **k8sInteg** group

```bash
kubectl create namespace integration
kubectl create namespace development
```

#### Configuring access to development namespace

We create a kubernetes `role` and `rolebinding` in the development namespace giving full access to the kubernetes user **dev-user**

```bash
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

The role we define will give full access to everything in that namespace. It is a Role, and not a ClusterRole, so it is going to be applied only in the **development** namespace.

> feel free to adapt or duplicate to any namespace you prefer.

#### Configuring access to integration namespace

We create a kubernetes `role` and `rolebinding` in the integration namespace for full access with the kubernetes user **integ-user**

```bash
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
  name: integ-role-binding
subjects:
- kind: User
  name: integ-user
roleRef:
  kind: Role
  name: integ-role
  apiGroup: rbac.authorization.k8s.io
EOF
```

The role we define will give full access to everything in that namespace. It is a `Role`, and not a `ClusterRole`, so it is going to be applied only in the **integration** namespace.
