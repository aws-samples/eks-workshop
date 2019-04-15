---
title: "App Mesh Cleanup"
date: 2018-11-13T16:32:30+09:00
weight: 40
draft: false
---

When you're done experimenting and want to delete all resources created during this tutorial, you can uninstall the components by running 'kubectl delete ...' , along with de-install scripts for the injector.  

For ease of use, these commands have all been packaged into the cleanup script, which can be run via:

```
./cleanup.sh
```

The above script will not delete any nodes in your k8s cluster.
