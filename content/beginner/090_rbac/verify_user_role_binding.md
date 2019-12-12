---
title: "Verify the Role and Binding"
date: 2018-10-03T10:14:46-07:00
draft: false
weight: 60
---

Now that the user, Role, and RoleBinding are defined, lets switch back to rbac-user, and test.

To switch back to rbac-user, issue the following command that sources the rbac-user env vars, and verifies they've taken:

```
. rbacuser_creds.sh; aws sts get-caller-identity
```

You should see output reflecting that you are logged in as rbac-user.

As rbac-user, issue the following to get pods in the rbac namespace:

```
kubectl get pods -n rbac-test
```

The output should be similar to:

{{< output >}}
NAME                    READY     STATUS    RESTARTS   AGE
nginx-55bd7c9fd-kmbkf   1/1       Running   0          23h
{{< /output >}}

Try running the same command again, but outside of the rbac-test namespace:

```
kubectl get pods -n kube-system
```

You should get an error similar to:
{{< output >}}
No resources found.
Error from server (Forbidden): pods is forbidden: User "rbac-user" cannot list resource "pods" in API group "" in the namespace "kube-system"
{{< /output >}}

Because the role you are bound to does not give you access to any namespace other than rbac-test.
