---
title: "Download and Install Istio CLI"
date: 2018-11-13T16:36:43+09:00
weight: 20
draft: false
---

Before we can get started configuring Istio we’ll need to first install the command line tools that you will interact with. To do this run the following.

```
cd ~/environment

curl -L https://github.com/istio/istio/releases/download/1.0.5/istio-1.0.5-linux.tar.gz | tar xvfz -

// version can be different as istio gets upgraded
cd istio-1.0.5

sudo mv -v bin/istioctl /usr/local/bin/
```
