---
title: "Create the Worker ConfigMap"
date: 2018-08-07T12:00:40-07:00
weight: 50
draft: true
---

The terraform state also contains a config-map we can use for our EKS workers.

View the configmap:
```
terraform output config-map
```

Save the config-map:
```
terraform output config-map > /tmp/config-map-aws-auth.yml
```

Apply the config-map:
```
kubectl apply -f /tmp/config-map-aws-auth.yml
```

Confirm your Nodes:
```
kubectl get nodes
```

#### Congratulations!
You now have a fully working Amazon EKS Cluster that is ready to use!
