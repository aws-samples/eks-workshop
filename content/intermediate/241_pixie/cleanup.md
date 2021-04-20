---
title: "Cleanup"
date: 2021-5-01T09:00:00-00:00
weight: 26
draft: false
---

Delete the microservices demo application:
```bash
px demo delete px-sock-shop
```

Delete Pixie from the cluster:
```bash
px delete --clobber
```

Remove the Pixie CLI:
```bash
rm -rf ${HOME}/ec2-user/bin/px
```

Delete the Nodegroup:
```bash
envsubst < clusterconfig.yaml | eksctl delete nodegroup -f -  --approve
```