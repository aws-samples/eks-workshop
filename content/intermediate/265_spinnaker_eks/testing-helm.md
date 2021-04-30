---
title: "Testing Helm-Based Pipeline"
weight: 60
draft: false
---

We now have Spinnaker Service up and running, we will now loginto Spinnaker UI.

#### Clone Application Git Repo
```
cd ~/environment
git clone https://github.com/aws-containers/eks-microservice-demo.git
cd eks-microservice-demo
```

#### Spinnaker UI

##### Create application
Click on `Create Application` and enter details as `Product-Detail`
![Spinnaker](/images/spinnnaker/proddetail.png)

##### Create Pipeline
Click on `Pipelines` under `test-application` and click on `Configure a new pipeline` and add the name as below.
![Spinnaker](/images/spinnnaker/helmpipeline.png)

##### Setup Trigger
Click on `Configuration` under `Pipelines` and click on `Add Trigger`. This is the ECR registry we had setup in Spinnaker manifest in [Configure Artifact](/265_spinnaker_eks/configure_artifact/) chapter. Follow the below setup and click on "Save Changes".
![Spinnaker](/images/spinnnaker/trigger.png)

##### Setup Bake Stage
- Click on `Add Stage` and select `Bake Manifest` from the dropdown 
- Select "create new artifact" for **Expected Artifact** and select the Git account that shows in dropdown. This is the Git account we had setup in Spinnaker manifest in [Configure Artifact](/265_spinnaker_eks/configure_artifact/) chapter. And then enter the below git location.
	
	https://api.github.com/repos/aws-containers/eks-microservice-demo/contents/spinnaker/proddetail-0.1.0.tgz
- Select "create new artifact" for **Expected Artifact** and select the Git account that shows in dropdown. This is the Git account we had setup in Spinnaker manifest in [Configure Artifact](/265_spinnaker_eks/configure_artifact/) chapter. And then enter the below git location.
	
	https://api.github.com/repos/aws-containers/eks-microservice-demo/contents/spinnaker/helm-chart/values.yaml

![Spinnaker](/images/spinnnaker/bake.png)

- Edit the `Produces Artifact` and change the name to `helm-produced-artifact` and click on **Save Changes**.

![Spinnaker](/images/spinnnaker/bake2.png)

![Spinnaker](/images/spinnnaker/bake3.png)

##### Setup Deploy Stage
- Click on `Add Stage` and select `Deploy (Manifest)` from the dropdown for **Type**, and give a name as `Bake proddetail`.
- Select **Type** as `spinnaker-workshop` from the dropdown for **Account**. This is the EKS account we had setup in Spinnaker manifest in [Add EKS Account](265_spinnaker_eks/add_eks-cccount/) chapter.
- Select `helm-produced-artifact`  from the dropdown for **Manifest Artifact** and click on **Save Changes**.

![Spinnaker](/images/spinnnaker/bake3.png)

#### Test Deployment

##### Push new container image to ECR for testing trigger

To ensure that the ECR trigger will work in Spinnaker UI:

- First change the content of the file to generate a new docker image digest. ECR trigger in Spinnaker does not work for same docker image digest. Go to `~/environment/eks-microservice-demo/apps/detail/app.js` and add a comment to first line of the file like below
```
// commenting for file for docker image generation
```
-  Ensure that the image tag (APP_VERSION) you are adding below does not exist in the ECR repository `eks-microservice-demo/test`

And then run the below command in Cloud9 terminal.

```
cd ~/environment/eks-microservice-demo
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
export APP_VERSION=1.0
export ECR_REPOSITORY=eks-microservice-demo/test
TARGET=$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$APP_VERSION
docker build -t $TARGET apps/detail --no-cache
docker push $TARGET

```

{{% notice info %}} 
Building/Pushing Container images first time to ECR may take around 3-5 minutes 
{{% /notice %}}

##### Watch Pipleline getting triggered

![Spinnaker](/images/spinnnaker/test.png)

- You will see that docker push triggers a deployment in the pipeline.

![Spinnaker](/images/spinnnaker/test2.png)

![Spinnaker](/images/spinnnaker/test3.png)

- Below are the `Execution Details` of pipeline

![Spinnaker](/images/spinnnaker/test4.png)

![Spinnaker](/images/spinnnaker/test5.png)

##### Get deploymet details

- You can see the deployment of `frontend` and `detail` service below.

![Spinnaker](/images/spinnnaker/hdeploy1.png)

- Click on the LoadBalancer link below and paste it on browser like http://a991d7csdsdsdsdsdsds-1949669176.XXXXX.elb.amazonaws.com:9000/

![Spinnaker](/images/spinnnaker/hdeploy2.png)

- You should see the service up and running as below.

![Spinnaker](/images/spinnnaker/hdeploy3.png)

- You can also go to Cloud9 terminal and confirm the deployment details

```
	kubectl get all -n detail
	NAME                                   READY   STATUS    RESTARTS   AGE
	pod/frontend-677dd7d654-nzxbq          1/1     Running   0          152m
	pod/nginx-deployment-6dc677db6-jchq8   1/1     Running   0          22h
	pod/proddetail-65cf5d598c-h9l7s        1/1     Running   0          152m

	NAME                 TYPE           CLUSTER-IP      EXTERNAL-IP                                                               PORT(S)          AGE
	service/frontend     LoadBalancer   10.100.73.76    a991d7csdsdsdsdsdsds-1949669176.XXXXX.elb.amazonaws.com   9000:30229/TCP   152m
	service/proddetail   ClusterIP      10.100.37.158   <none>                                                                    3000/TCP         152m

	NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
	deployment.apps/frontend           1/1     1            1           152m
	deployment.apps/nginx-deployment   1/1     1            1           22h
	deployment.apps/proddetail         1/1     1            1           152m

	NAME                                         DESIRED   CURRENT   READY   AGE
	replicaset.apps/frontend-677dd7d654          1         1         1       152m
	replicaset.apps/nginx-deployment-6dc677db6   1         1         1       22h
	replicaset.apps/proddetail-65cf5d598c        1         1         1       152m
```

