---
title: "Download and Install Istio CLI"
date: 2018-11-13T16:36:43+09:00
weight: 20
draft: false
---

Before we can get started configuring Istio we’ll need to first install the command line tools that you will interact with. To do this run the following.

```
cd ~/environment

curl -L https://git.io/getLatestIstio | sh -

// version can be different as istio gets upgraded
cd istio-1.0.3

sudo mv -v bin/istioctl /usr/local/bin/
```
