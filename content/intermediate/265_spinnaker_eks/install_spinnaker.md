---
title: "Install Spinnaker"
weight: 50
draft: false
---

By now we have completed our configuration for Spinnaker and the `SpinnakerService` manifest located at deploy/spinnaker/basic/spinnakerservice.yml should look like below:

{{< output >}}
apiVersion: spinnaker.io/v1alpha2
kind: SpinnakerService
metadata:
  name: spinnaker
spec:
  spinnakerConfig:
    config:
      version: $SPINNAKER_VERSION   # the version of Spinnaker to be deployed
      persistentStorage:
        persistentStoreType: s3
        s3:
          bucket: $S3_BUCKET
          rootFolder: front50
          region: $AWS_REGION
          accessKeyId: $AWS_ACCESS_KEY_ID
          secretAccessKey: $AWS_SECRET_ACCESS_KEY
      deploymentEnvironment:
        sidecars:
          spin-clouddriver:
          - name: token-refresh
            dockerImage: quay.io/skuid/ecr-token-refresh:latest
            mountPath: /etc/passwords
            configMapVolumeMounts:
            - configMapName: token-refresh-config
              mountPath: /opt/config/ecr-token-refresh
      features:
        artifacts: true
      artifacts:
        github:
          enabled: true
          accounts:
          - name: $GITHUB_USER
            token: $GITHUB_TOKEN  # GitHub's personal access token. This fields supports `encrypted` references to secrets.
      providers:
          dockerRegistry:
            enabled: true
          kubernetes:
            enabled: true
            accounts:
            - name: spinnaker-workshop
              requiredGroupMembership: []
              providerVersion: V2
              permissions:
              dockerRegistries:
                - accountName: my-ecr-registry
              configureImagePullSecrets: true
              cacheThreads: 1
              namespaces: [spinnaker,detail]
              omitNamespaces: []
              kinds: []
              omitKinds: []
              customResources: []
              cachingPolicies: []
              oAuthScopes: []
              onlySpinnakerManaged: false
              kubeconfigFile: kubeconfig-sp  # File name must match "files" key
            primaryAccount: spinnaker-workshop  # Change to a desired account from the accounts array
    profiles:
        clouddriver:
          dockerRegistry:
            enabled: true
            primaryAccount: my-ecr-registry
            accounts:
            - name: my-ecr-registry
              address: https://$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
              username: AWS
              passwordFile: /etc/passwords/my-ecr-registry.pass
              trackDigests: true
              repositories:
              - $ECR_REPOSITORY
        igor:
          docker-registry:
            enabled: true
    files: 
        kubeconfig-sp: |
          <FILE CONTENTS HERE> # Content from kubeconfig created by Spinnaker Tool
  # spec.expose - This section defines how Spinnaker should be publicly exposed
  expose:
    type: service  # Kubernetes LoadBalancer type (service/ingress), note: only "service" is supported for now
    service:
      type: LoadBalancer
 {{< /output >}} 

#### Install Spinnaker Service

Confirm if all the environment variables is set correctly

  ```
  echo $ACCOUNT_ID
  echo $AWS_REGION
  echo $SPINNAKER_VERSION
  echo $GITHUB_USER
  echo $GITHUB_TOKEN
  echo $S3_BUCKET
  echo $AWS_ACCESS_KEY_ID
  echo $AWS_SECRET_ACCESS_KEY
  echo $ECR_REPOSITORY
  ```

{{% notice info %}}
If you do not see output from the above command for all the Environment Variables, do not proceed to next step
{{% /notice %}}

```
cd ~/environment/spinnaker-operator/
envsubst < deploy/spinnaker/basic/spinnakerservice.yml | kubectl -n spinnaker apply -f -
```
{{< output >}}
spinnakerservice.spinnaker.io/spinnaker created
{{< /output >}} 

{{% notice tip %}}
It will take some time to bring up all the pods, so wait for few minutes..
{{% /notice %}}

```
 # Get all the resources created
kubectl get svc,pod -n spinnaker
```
{{< output >}}
NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)        AGE
service/spin-clouddriver   ClusterIP      10.1x0.xx.71    <none>                                                                    7002/TCP       8d
service/spin-deck          LoadBalancer   10.1x0.yy.xx    ae33c1a7185b14yyyy-1275091989.us-east-2.elb.amazonaws.com   80:32392/TCP   8d
service/spin-echo          ClusterIP      10.1x0.54.127    <none>                                                                    8089/TCP       8d
service/spin-front50       ClusterIP      10.1x0.xx.241   <none>                                                                    8080/TCP       8d
service/spin-gate          LoadBalancer   10.1x0.75.xx    ac3a38db81ebXXXX-1555475316.us-east-2.elb.amazonaws.com   80:32208/TCP   8d
service/spin-igor          ClusterIP      10.1x0.yy.xx    <none>                                                                    8088/TCP       8d
service/spin-orca          ClusterIP      10.xx.64.yy    <none>                                                                    8083/TCP       8d
service/spin-redis         ClusterIP      10.1x0.xx.242    <none>                                                                    6379/TCP       1x0
service/spin-rosco         ClusterIP      10.1x0.yy.xx   <none>                                                                    8087/TCP       8d

NAME                                    READY   STATUS    RESTARTS   AGE
pod/spin-clouddriver-7c5dbf658b-spl64   2/2     Running   0          8d
pod/spin-deck-7f785d675f-2q4q8          1/1     Running   0          8d
pod/spin-echo-d9b7799b4-4wjnn           1/1     Running   0          8d
pod/spin-front50-76d9f8bd58-n96sl       1/1     Running   0          8d
pod/spin-gate-7f48c76b55-bpc22          1/1     Running   0          8d
pod/spin-igor-5c98f5b46f-mcmvs          1/1     Running   0          8d
pod/spin-orca-6bd7c69f-mml4c            1/1     Running   0          8d
pod/spin-redis-7f7d9659bf-whkf7         1/1     Running   0          8d
pod/spin-rosco-7c6f77c64c-2qztw         1/1     Running   0          8d
 {{< /output >}} 

 ```
 # Watch the install progress.
kubectl -n spinnaker get spinsvc spinnaker -w
```
{{< output >}}
NAME        VERSION   LASTCONFIGURED   STATUS   SERVICES   URL
spinnaker   1.24.0    3h8m             OK       9          http://ae33c1a7185b1402mmmmm-1275091989.us-east-2.elb.amazonaws.com
{{< /output >}} 

#### Test the setup on Spinnaker UI

##### Access Spinakker UI

Grab the load balancer url from the previous step, and load into the browser, you should see the below Spinnaker UI
![Spinnaker](/images/spinnnaker/ui.png)

##### Create a test application
Click on `Create Application` and enter details.
![Spinnaker](/images/spinnnaker/application.png)

##### Create a test pipeline
Click on `Pipelines` under `test-application` and click on `Configure a new pipeline` and add the name.
![Spinnaker](/images/spinnnaker/pipeline.png)

Click on `Add Stage` and select `Deploy (Manifest)` from the dropdown for **Type**, select `spinnaker-workshop` from the dropdown for **Account** and put the below yaml into the Manifest text area and click on "Save Changes".

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```
![Spinnaker](/images/spinnnaker/manifest1.png)

In the Spinnaker UI, Go to `Pipelines` and click on `Start Manual Execution`
![Spinnaker](/images/spinnnaker/manual.png)
![Spinnaker](/images/spinnnaker/step1.png)

You will see the pipeline getting triggered and is in progress
![Spinnaker](/images/spinnnaker/step2.png)

After few seconds, the pipleine is successful
![Spinnaker](/images/spinnnaker/step3.png)

Clicking on `execution details` you can see the detail of deployment
![Spinnaker](/images/spinnnaker/details.png)
![Spinnaker](/images/spinnnaker/details1.png)
![Spinnaker](/images/spinnnaker/details2.png)

Go to `Clusters` and verify the deployment
![Spinnaker](/images/spinnnaker/deploy1.png)
![Spinnaker](/images/spinnnaker/deploy2.png)

You can also go to Cloud9 terminal and verify the deployment
```
kubectl get deployment nginx-deployment -n spinnaker

kubectl get pods -l app=nginx -n spinnaker
```
{{< output >}}
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   1/1     1            1           108s

NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-6dc677db6-jchq8   1/1     Running   0          3m25s
{{< /output >}} 

Congratulations! You have successfully installed Spinnaker and created a test pipeline in Spinnaker and deployed the ngnix manifest to EKS cluster.




