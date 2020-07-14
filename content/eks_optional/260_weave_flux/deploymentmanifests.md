---
title: "Deploy from Manifests"
date: 2018-10-087T08:30:11-07:00
weight: 25
draft: false
---

Now we are ready to use Weave Flux to deploy the hello world application into our Amazon EKS cluster.  To do this we will clone our GitHub config repository (k8s-config) and then commit Kubernetes manifests to deploy. 


```
cd ..
git clone https://github.com/${YOURUSER}/k8s-config.git     
cd k8s-config
mkdir charts namespaces releases workloads
```

Create a namespace Kubernetes manifest. 

```
cat << EOF > namespaces/eks-example.yaml
apiVersion: v1
kind: Namespace
metadata:
  labels:
    name: eks-example
  name: eks-example
EOF
```

Create a deployment Kubernetes manifest.  

{{% notice info %}}
Update the image below to point to your ECR repository and image tag (**Do NOT use latest**).  You can find your Image URI from the [Amazon ECR Console](https://console.aws.amazon.com/ecr/repositories/eks-example/).  Replace YOURACCOUNT and YOURTAG)
{{% /notice %}}

```
cat << EOF > workloads/eks-example-dep.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: eks-example
  namespace: eks-example
  labels:
    app: eks-example
  annotations:
    # Container Image Automated Updates
    flux.weave.works/automated: "true"
    # do not apply this manifest on the cluster
    #flux.weave.works/ignore: "true"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: eks-example
  template:
    metadata:
      labels:
        app: eks-example
    spec:
      containers:
      - name: eks-example
        image: YOURACCOUNT.dkr.ecr.us-east-1.amazonaws.com/eks-example:YOURTAG
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
          name: http
          protocol: TCP
        livenessProbe:
          httpGet:
            path: /
            port: http
        readinessProbe:
          httpGet:
            path: /
            port: http
EOF
```

Above you see 2 Kubernetes annotations for Flux.  

* flux.weave.works/automated tells Flux whether the container image should be automatically updated.  
* flux.weave.works/ignore is commented out, but could be used to tell Flux to temporarily ignore the deployment.  

Finally, create a service manifest to enable a load balancer to be created.

```
cat << EOF > workloads/eks-example-svc.yaml
apiVersion: v1
kind: Service
metadata:
  name: eks-example
  namespace: eks-example
  labels:
    app: eks-example
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: http
      protocol: TCP
      name: http
  selector:
    app: eks-example
EOF
```

Now commit the changes and push to your repository.  

```
git add . 
git commit -am "eks-example-deployment"
git push 
```

Check the logs of your Flux pod.  It will pull config from the k8s-config repository every 5 minutes.  Ensure you replace the pod name below with the name in your deployment.  

```
kubectl get pods -n flux

kubectl logs flux-5bd7fb6bb6-4sc78 -n flux
```

Now get the URL for the load balancer (LoadBalancer Ingress) and connect via your browser (this may take a couple minutes for DNS).

```
kubectl describe service eks-example -n eks-example
```

Make a change to the eks-example source code and push a new change.  

```
cd ../eks-example
vi src/index.html
   # Change the <title> AND <h> to Hello World Version 2

git commit -am "v2 Updating home page"
git push
```

Now you can watch in the [CodePipeline console](https://console.aws.amazon.com/codesuite/codepipeline/pipelines) for the new image build to complete.  This will take a couple minutes.  Once complete, you will see a new image land in your [Amazon ECR repository](https://console.aws.amazon.com/ecr/repositories/eks-example/). 
Monitor the **kubectl logs** for the Flux pod and you should see it update the configuration within five minutes.  

Verify the web page has updated by refreshing the page in your browser.  

Your boss calls you late at night and tells you that people are complaining about the deployment.  We need to back it out immediately!  We could modify the code in eks-example and trigger a new image build and deploy.  However, we can also use git to revert the config change in k8s-config.  Lets take that approach.

```
cd ../k8s-config
git pull 

git log --oneline

git revert HEAD
   # Save the commit message

git log --oneline 

git push
```

You should now be able to watch logs for the Flux pod and it will pull the config change and roll out the previous image.  Check your URL in the browser to ensure it is reverted.  

Phew!  Disaster averted.  


