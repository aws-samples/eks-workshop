---
title: "Cleanup"
date: 2021-5-01T09:00:00-00:00
weight: 26
draft: false
---

### Next Steps

Congratulations on completing the Pixie tutorial.

- To export data from the Pixie platform, check out the [API](https://docs.pixielabs.ai/using-pixie/api-quick-start/).
- To see a list of the pre-built PxL scripts, go [here](https://github.com/pixie-labs/pixie/tree/main/src/pxl_scripts).
- To learn how to write a custom PxL script, see the PxL [tutorial](https://docs.pixielabs.ai/tutorials/pxl-scripts/).
- To check out the open source code, see the [Github Repo](https://github.com/pixie-labs/pixie)

Ask questions and get help from the [Pixie's Community Slack](http://slackin.withpixie.ai).

### Cleanup

Delete the microservices demo application:
```bash
kubectl delete namespace px-sock-shop
```

Delete Pixie from the cluster:
```bash
px delete --clobber
```

Remove the Pixie CLI:
```bash
rm -rf ${HOME}/ec2-user/bin/px
```

Delete the node group:
```bash
envsubst < clusterconfig.yaml | eksctl delete nodegroup -f -  --approve
```