---
title: "Deploy the Backend API"
date: 2018-08-07T08:30:11-07:00
weight: 30
draft: true
---

For the backend app we're going to deploy a `Go` webserver that connects into a
DynamoDB table for persistance. We will create a new manifst file and apply it.

Copy and paste this manifest so that we can `kubectl apply` it.

```
cat <<EoF > ~/environment/dynamo-app.yaml
---
apiVersion: operator.aws/v1alpha1
kind: DynamoDB
metadata:
  name: dynamo-table
spec:
  hashAttribute:
    name: name
    type: S
  rangeAttribute:
    name: created_at
    type: S
  readCapacityUnits: 5
  writeCapacityUnits: 5
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: http-server
    name: http
  type: LoadBalancer
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: frontend
  labels:
    app: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: christopherhein/dynamoapp:latest
        imagePullPolicy: Always
        env:
        - name: TABLE_NAME
          valueFrom:
            configMapKeyRef:
              name: dynamo-table
              key: tableName
        resources:
          requests:
            memory: "512m"
            cpu: "512m"
        ports:
        - name: http-server
          containerPort: 8080
EoF
```

We can kubectl apply this manifest:

```
kubectl apply -f ~/environment/dynamo-app.yaml
```

While this starts to deploy let's open up a `watch` on the pod to see it waiting
patiently for the table to come online and for the AWS Service Operator to
create the `ConfigMap`.

```
kubectl get pods -w
```

Look for `CreateContainerConfigError`. Which after 30 seconds should update to a
`Running` status after the Table is created and the `ConfigMap` is written.

To see what this deployed we can get the **EXTERNAL-IP** from the `service.`

```
export ELB_ENDPOINT=http://$(kubectl get svc frontend --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
echo "${ELB_ENDPOINT}"
```

Copy and Paste that URL into a new browser tab and you should see a JSON
response.

Let's update the S3 bucket to use this new backend.
