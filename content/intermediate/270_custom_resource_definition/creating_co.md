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
    creationTimestamp: "2022-07-15T12:15:25Z"
    generation: 1
    name: my-new-cron-object
    namespace: default
    resourceVersion: "822447"
    uid: d6698dd8-69f4-4ffa-9e83-0549f7162cdd
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
Annotations:  <none>
API Version:  stable.example.com/v1
Kind:         CronTab
Metadata:
  Creation Timestamp:  2022-07-15T12:15:25Z
  Generation:          1
  Managed Fields:
    API Version:  stable.example.com/v1
    Fields Type:  FieldsV1
    fieldsV1:
      f:metadata:
        f:annotations:
          .:
          f:kubectl.kubernetes.io/last-applied-configuration:
      f:spec:
        .:
        f:cronSpec:
        f:image:
    Manager:         kubectl-client-side-apply
    Operation:       Update
    Time:            2022-07-15T12:15:25Z
  Resource Version:  822447
  UID:               d6698dd8-69f4-4ffa-9e83-0549f7162cdd
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
Audit-Id: 1d451453-0edf-49ea-95d3-612d64070a53
Cache-Control: no-cache, private
Content-Length: 943
Content-Type: application/json
Date: Fri, 15 Jul 2022 12:52:47 GMT
X-Kubernetes-Pf-Flowschema-Uid: 16b0834b-6ac6-4b7e-8b43-505208a6efc8
X-Kubernetes-Pf-Prioritylevel-Uid: f3c0805c-6d2b-493b-a958-724b2adeb80b

{"apiVersion":"stable.example.com/v1","kind":"CronTab","metadata":{"annotations":{"kubectl.kubernetes.io/last-applied-configuration":"{\"apiVersion\":\"stable.example.com/v1\",\"kind\":\"CronTab\",\"metadata\":{\"annotations\":{},\"name\":\"my-new-cron-object\",\"namespace\":\"default\"},\"spec\":{\"cronSpec\":\"* * * * */5\",\"image\":\"my-awesome-cron-image\"}}\n"},"creationTimestamp":"2022-07-15T12:15:25Z","generation":1,"managedFields":[{"apiVersion":"stable.example.com/v1","fieldsType":"FieldsV1","fieldsV1":{"f:metadata":{"f:annotations":{".":{},"f:kubectl.kubernetes.io/last-applied-configuration":{}}},"f:spec":{".":{},"f:cronSpec":{},"f:image":{}}},"manager":"kubectl-client-side-apply","operation":"Update","time":"2022-07-15T12:15:25Z"}],"name":"my-new-cron-object","namespace":"default","resourceVersion":"822447","uid":"d6698dd8-69f4-4ffa-9e83-0549f7162cdd"},"spec":{"cronSpec":"* * * * */5","image":"my-awesome-cron-image"}}
```
