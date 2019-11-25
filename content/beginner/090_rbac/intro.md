---
title: "What is RBAC?"
date: 2018-10-03T10:14:46-07:00
draft: false
weight: 10
---

According to [the official kubernetes docs:](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

> Role-based access control (RBAC) is a method of regulating access to computer or network resources based on the roles of individual users within an enterprise.

The core logical components of RBAC are:

**Entity**  
A group, user, or service account (an identity representing an application that
wants to execute certain operations (actions) and requires permissions to do so).

**Resource**  
A pod, service, or secret that the entity wants to access using the certain operations.

**Role**  
Used to define rules for the actions the entity can take on various resources.

**Role binding**  
This attaches (binds) a role to an entity, stating that the set of rules define the
actions permitted by the attached entity on the specified resources.

There are two types of Roles (Role, ClusterRole) and the respective bindings (RoleBinding, ClusterRoleBinding).
These differentiate between authorization in a namespace or cluster-wide.

**Namespace**  

Namespaces are an excellent way of creating security boundaries, they also provide a unique scope for object names as the 'namespace' name implies. They are intended to be used in multi-tenant environments to create virtual kubernetes clusters on the same physical cluster.


### Objectives for this module
In this module, we're going to explore k8s RBAC by creating an IAM user called rbac-user who is authenticated to access the EKS cluster but is only authorized (via RBAC) to list, get, and watch pods and deployments in the 'rbac-test' namespace.

To achieve this, we'll create an IAM user, map that user to a kubernetes role, then perform kubernetes actions under that user's context.
