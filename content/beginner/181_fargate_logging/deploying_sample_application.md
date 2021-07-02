---
title: "Deploying a sample application"
date: 2018-08-07T08:30:11-07:00
weight: 20
---

### Deploy a sample pod.

```bash
cat > sample-app.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  namespace: fargate
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - name: http
              containerPort: 80
EOF

kubectl apply -f sample-app.yaml
```

Watch the created pods and wait until they are up and running

```bash
kubectl get pods --watch -n fargate
```

Execute a curl command inside one of the pods to create logs

```bash
kubectl exec -it $(kubectl get pods -n fargate -o json | jq -r '.items[0].metadata.name') -- curl localhost
```

Open [Cloudwatch](https://console.aws.amazon.com/cloudwatch/) and navigate to `Log Groups` in the navigation menu. 

![Log Groups Overview](/images/fargate-logging/CloudWatch_Management_Console.png)

Open the Log group and navigate to the log stream. You should be able to see see nginx access logs.
