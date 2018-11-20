# AWS X-Ray DaemonSet

Foundation for the example [AWS X-Ray](https://aws.amazon.com/xray/) DaemonSet in the [EKS Workshop](https://eksworkshop.com/)

Based on the [aws-xray-kubernetes](https://github.com/aws-samples/aws-xray-kubernetes) project

See the [Application Tracing on Kubernetes with AWS X-Ray](https://aws.amazon.com/blogs/compute/application-tracing-on-kubernetes-with-aws-x-ray/) blog post for more info

**Command reference**

Deploy
```
kubectl apply -f xray-k8s-daemonset.yaml
```

Describe
```
kubectl describe daemonset xray-daemon
```

List the pods
```
kubectl get pod --selector app=xray-daemon
```

Get logs for pods
```
kubectl logs -l app=xray-daemon
```

Delete
```
kubectl delete -f xray-k8s-daemonset.yaml
```

