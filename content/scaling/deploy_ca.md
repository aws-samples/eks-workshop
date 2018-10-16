---
title: "Configure Cluster Autoscaler (CA)"
date: 2018-08-07T08:30:11-07:00
weight: 30
draft: true
---

### Configure the Cluster Autoscaler
Copy the following text and paste into your Cloud9 Terminal

```
mkdir ~/environment/cluster-autoscaler
cat <<EoF> ~/environment/cluster-autoscaler/ca_example.yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
  name: cluster-autoscaler
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: cluster-autoscaler
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
rules:
- apiGroups: [""]
  resources: ["events","endpoints"]
  verbs: ["create", "patch"]
- apiGroups: [""]
  resources: ["pods/eviction"]
  verbs: ["create"]
- apiGroups: [""]
  resources: ["pods/status"]
  verbs: ["update"]
- apiGroups: [""]
  resources: ["endpoints"]
  resourceNames: ["cluster-autoscaler"]
  verbs: ["get","update"]
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["watch","list","get","update"]
- apiGroups: [""]
  resources: ["pods","services","replicationcontrollers","persistentvolumeclaims","persistentvolumes"]
  verbs: ["watch","list","get"]
- apiGroups: ["extensions"]
  resources: ["replicasets","daemonsets"]
  verbs: ["watch","list","get"]
- apiGroups: ["policy"]
  resources: ["poddisruptionbudgets"]
  verbs: ["watch","list"]
- apiGroups: ["apps"]
  resources: ["statefulsets"]
  verbs: ["watch","list","get"]
- apiGroups: ["storage.k8s.io"]
  resources: ["storageclasses"]
  verbs: ["watch","list","get"]

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  name: cluster-autoscaler
  namespace: kube-system
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["create"]
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["cluster-autoscaler-status"]
  verbs: ["delete","get","update"]

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: cluster-autoscaler
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-autoscaler
subjects:
  - kind: ServiceAccount
    name: cluster-autoscaler
    namespace: kube-system

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: cluster-autoscaler
  namespace: kube-system
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: cluster-autoscaler
subjects:
  - kind: ServiceAccount
    name: cluster-autoscaler
    namespace: kube-system

---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: kube-system
  labels:
    app: cluster-autoscaler
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cluster-autoscaler
  template:
    metadata:
      labels:
        app: cluster-autoscaler
    spec:
      serviceAccountName: cluster-autoscaler
      containers:
        - image: k8s.gcr.io/cluster-autoscaler:v1.2.2
          name: cluster-autoscaler
          resources:
            limits:
              cpu: 100m
              memory: 300Mi
            requests:
              cpu: 100m
              memory: 300Mi
          command:
            - ./cluster-autoscaler
            - --v=4
            - --stderrthreshold=info
            - --cloud-provider=aws
            - --skip-nodes-with-local-storage=false
            - --nodes=2:8:<AUTOSCALING GROUP NAME>
          env:
            - name: AWS_REGION
              value: us-west-2
          volumeMounts:
            - name: ssl-certs
              mountPath: /etc/ssl/certs/ca-certificates.crt
              readOnly: true
          imagePullPolicy: "Always"
      volumes:
        - name: ssl-certs
          hostPath:
            path: "/etc/ssl/certs/ca-bundle.crt"
---
EoF
```
Cluster Autoscaler for AWS provides integration with Auto Scaling groups. It enables users to choose from four different options of deployment:

* **One Auto Scaling group** - This is what we will use
* Multiple Auto Scaling groups
* Auto-Discovery
* Master Node setup

### Configure the ASG

Collect the name of the Auto Scaling Group (ASG) containing your worker nodes. You can find it in the console by following this [link](https://us-west-2.console.aws.amazon.com/ec2/autoscaling/home?region=us-west-2#AutoScalingGroups:view=details;filter=eksctl)

![ASG](/images/scaling-asg.png)

Check the box beside the ASG and click `Actions` and `Edit`

Change the following settings:

* Min: **2**
* Max: **8**

![ASG Config](/images/scaling-asg-config.png)

Click `Save`

### Configure the Cluster Autoscaler

Using the file browser on the left, open cluster-autoscaler/ca-example.yaml.

Replace the placeholder text `<AUTOSCALING GROUP NAME>` with the ASG name that you copied in the previous step and **Save** the file.

```
 command:
            - ./cluster-autoscaler
            - --v=4
            - --stderrthreshold=info
            - --cloud-provider=aws
            - --skip-nodes-with-local-storage=false
            - --nodes=2:8:<AUTOSCALING GROUP NAME>
```
This command contains all of the configuration for the Cluster Autoscaler. The primary config is the `--nodes` flag. This specifies the minimum nodes **(2)**, max nodes **(8)** and **ASG Name**.

Although Cluster Autoscaler is the de facto standard for automatic scaling in K8s, it is not part of the main release. We deploy it like any other pod in the kube-system namespace, like other management pods. Those management pods would prevent the cluster from scaling down. We are overriding this default behavior by passing in the `–-skip-nodes-with-system-pods=false flag`

### Create an IAM Policy
We need to configure an inline policy and add it to the EC2 instance profile of the worker nodes

Collect the Instance Profile and Role NAME from the CloudFormation Stack
```
INSTANCE_PROFILE_PREFIX=$(aws cloudformation describe-stacks --stack-name eksctl-eksworkshop-eksctl-nodegroup-0 | jq -r '.Stacks[].Outputs[].ExportName' | sed 's/:.*//')
INSTANCE_PROFILE_NAME=$(aws iam list-instance-profiles | jq -r '.InstanceProfiles[].InstanceProfileName' | grep $INSTANCE_PROFILE_PREFIX)
ROLE_NAME=$(aws iam get-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME | jq -r '.InstanceProfile.Roles[] | .RoleName')
```
```
mkdir ~/environment/asg_policy
cat <<EoF > ~/environment/asg_policy/k8s-asg-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup"
      ],
      "Resource": "*"
    }
  ]
}
EoF
aws iam put-role-policy --role-name $ROLE_NAME --policy-name ASG-Policy-For-Worker --policy-document file://~/environment/asg_policy/k8s-asg-policy.json
```

Validate that the policy is attached to the role
```
aws iam get-role-policy --role-name $ROLE_NAME --policy-name ASG-Policy-For-Worker
```

### Deploy the Cluster Autoscaler

```
kubectl apply -f ~/environment/cluster-autoscaler/ca_example.yaml
```

Watch the logs
```
kubectl logs -f deployment/cluster-autoscaler -n kube-system
```

#### We are now ready to scale our cluster






