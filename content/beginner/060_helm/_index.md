---
title: "Helm"
chapter: true
weight: 60
pre: '<i class="fa fa-film" aria-hidden="true"></i> '
tags:
  - beginner
  - CON203
  - CON205
  - CON206
---

# Helm

{{< youtube XIVCS2j_JxU >}}

{{% notice info %}}
This tutorial has been updated for Helm v3. In version 3, the Tiller component
was removed, which simplified operations and improved security.
{{% /notice %}}

{{% notice note %}}
If you need to migrate from Helm v2 to v3 [click here for the official documentation](https://helm.sh/blog/migrate-from-helm-v2-to-helm-v3/).
{{% /notice %}}

[Helm](https://helm.sh/) is a package manager for Kubernetes that packages
multiple Kubernetes resources into a single logical deployment unit called
a **Chart**. Charts are easy to create, version, share, and publish.

In this chapter, we'll cover [installing Helm](helm_intro).  Once installed,
we'll demonstrate how Helm can be used to [deploy a simple nginx
webserver](helm_nginx), and a more [sophisticated microservice](helm_micro).

![Helm Logo](/images/helm-logo.svg)
