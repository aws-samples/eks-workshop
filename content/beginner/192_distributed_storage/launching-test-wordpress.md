---
title: "Creating a simple, highly available Wordpress deployment"
date: 2020-11-03T00:00:00-03:00
weight: 10
draft: false
---

# Deploy Wordpress Pod

```
kubectl apply -f ~/environment/rook/cluster/examples/kubernetes/wordpress.yaml
kubectl apply -f ~/environment/rook/cluster/examples/kubernetes/mysql.yaml
timeout 20 watch -n 1 kubectl get svc -o wide
```

# test the deployment access the ELB adress found befor via the browser of your choise. Setup Wordpress 
# playing around e.g. upload a file/logo


# Drain the worker node your wordpress is running on to force relocating into other node/AZ

```
kubectl get po -o wide
kubectl drain <Pod Node>
timeout 20 watch -n 1 kubectl get po -o wide
```

# test the deployment access the ELB adress found befor via the browser of your choise. Setup Wordpress 
# logo/image still there. 

uncordon the node you drained to make it available again

```
kubectl get nodes
kubectl uncordon <Node with Scheduling Disabled>
```