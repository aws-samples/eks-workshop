---
title: "Create Custom Objects"
date: 2019-04-09T00:00:00-03:00
weight: 11
draft: false
---
After the CustomResourceDefinition object has been created, you can create custom objects. Custom objects can contain custom fields. These fields can contain arbitrary JSON. In the following example, the cronSpec and image custom fields are set in a custom object of kind CronTab. The kind CronTab comes from the spec of the CustomResourceDefinition object you created above.

If you save the following YAML to my-crontab.yaml:

```
cat <<EoF > ~/environment/my-crontab.yaml
apiVersion: "stable.example.com/v1"
kind: CronTab
metadata:
  name: my-new-cron-object
spec:
  cronSpec: "* * * * */5"
  image: my-awesome-cron-image
EoF
```

and create it:

```
kubectl apply -f my-crontab.yaml
```

You can then manage your CronTab objects using kubectl. For example:

```
kubectl get crontab
```

Should print a list like this:

```
NAME                 AGE
my-new-cron-object   6s
```

Resource names are not case-sensitive when using kubectl, and you can use either the singular or plural forms defined in the CRD, as well as any short names.

You can also view the raw YAML data:

```
kubectl get ct -o yaml
```

You should see that it contains the custom cronSpec and image fields from the yaml you used to create it:

```
apiVersion: v1
items:
- apiVersion: stable.example.com/v1
  kind: CronTab
  metadata:
    creationTimestamp: 2017-05-31T12:56:35Z
    generation: 1
    name: my-new-cron-object
    namespace: default
    resourceVersion: "285"
    selfLink: /apis/stable.example.com/v1/namespaces/default/crontabs/my-new-cron-object
    uid: 9423255b-4600-11e7-af6a-28d2447dc82b
  spec:
    cronSpec: '* * * * */5'
    image: my-awesome-cron-image
kind: List
metadata:
  resourceVersion: ""
  selfLink: ""
```
We can also describe the custom object with kubectl:
```
kubectl describe crontab
```
The output being something like this:
```
Name:         my-new-cron-object
Namespace:    default
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"stable.example.com/v1","kind":"CronTab","metadata":{"annotations":{},"name":"my-new-cron-object","namespace":"default"},"spec":{"cronSpe...
API Version:  stable.example.com/v1
Kind:         CronTab
Metadata:
  Creation Timestamp:  2019-05-09T18:10:35Z
  Generation:          1
  Resource Version:    3274450
  Self Link:           /apis/stable.example.com/v1/namespaces/default/crontabs/my-new-cron-object
  UID:                 bdc71d84-7285-11e9-a54d-0615623ca50e
Spec:
  Cron Spec:  * * * * */5
  Image:      my-awesome-cron-image
Events:       <none>
```
Or we can check the resource directly from the Kubernetes API. First, we start the proxy in one tab of the Cloud9 environment:

```
kubectl proxy --port=8080 --address='0.0.0.0' --disable-filter=true
```
 
And in another tab we check the existance of the Custom Resource
```
curl -i 127.0.0.1:8080/apis/stable.example.com/v1/namespaces/default/crontabs/my-new-cron-object
```
With the output:
```
HTTP/1.1 200 OK
Audit-Id: 04c5ce6e-5a45-4064-8139-6c2b848bc467
Content-Length: 707
Content-Type: application/json
Date: Thu, 09 May 2019 18:18:21 GMT

{"apiVersion":"stable.example.com/v1","kind":"CronTab","metadata":{"annotations":{"kubectl.kubernetes.io/last-applied-configuration":"{\"apiVersion\":\"stable.example.com/v1\",\"kind\":\"CronTab\",\"metadata\":{\"annotations\":{},\"name\":\"my-new-cron-object\",\"namespace\":\"default\"},\"spec\":{\"cronSpec\":\"* * * * */5\",\"image\":\"my-awesome-cron-image\"}}\n"},"creationTimestamp":"2019-05-09T18:10:35Z","generation":1,"name":"my-new-cron-object","namespace":"default","resourceVersion":"3274450","selfLink":"/apis/stable.example.com/v1/namespaces/default/crontabs/my-new-cron-object","uid":"bdc71d84-7285-11e9-a54d-0615623ca50e"},"spec":{"cronSpec":"* * * * */5","image":"my-awesome-cron-image"}}
```
