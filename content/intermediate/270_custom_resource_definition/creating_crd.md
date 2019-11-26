---
title: "Creating a CRD"
date: 2019-04-09T00:00:00-03:00
weight: 10
draft: false
---

When you create a new CustomResourceDefinition (CRD), the Kubernetes API Server creates a new RESTful resource path for each version you specify. The CRD can be either namespaced or cluster-scoped, as specified in the CRD’s scope field. As with existing built-in objects, deleting a namespace deletes all custom objects in that namespace. CustomResourceDefinitions themselves are non-namespaced and are available to all namespaces.

For example, if you save the following CustomResourceDefinition to resourcedefinition.yaml:

```
cat <<EoF > ~/environment/resourcedefinition.yaml
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  # name must match the spec fields below, and be in the form: <plural>.<group>
  name: crontabs.stable.example.com
spec:
  # group name to use for REST API: /apis/<group>/<version>
  group: stable.example.com
  # list of versions supported by this CustomResourceDefinition
  versions:
    - name: v1
      # Each version can be enabled/disabled by Served flag.
      served: true
      # One and only one version must be marked as the storage version.
      storage: true
  # either Namespaced or Cluster
  scope: Namespaced
  names:
    # plural name to be used in the URL: /apis/<group>/<version>/<plural>
    plural: crontabs
    # singular name to be used as an alias on the CLI and for display
    singular: crontab
    # kind is normally the CamelCased singular type. Your resource manifests use this.
    kind: CronTab
    # shortNames allow shorter string to match your resource on the CLI
    shortNames:
    - ct
EoF
```
And create it:

```
kubectl apply -f ~/environment/resourcedefinition.yaml
```

It might take a few seconds for the endpoint to be created. You can also watch the Established condition of your CustomResourceDefinition to be true or watch the discovery information of the API server for your resource to show up.

Now, let's check the recently created CRD.

```
kubectl get crd crontabs.stable.example.com
```

The result will be something like this:
```
NAME                          CREATED AT
crontabs.stable.example.com   2019-05-09T16:50:55Z
```

Now, let's see the Custom Resource in detail:
```
kubectl describe crd crontabs.stable.example.com
```

The output:
```
Name:         crontabs.stable.example.com
Namespace:    
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"apiextensions.k8s.io/v1beta1","kind":"CustomResourceDefinition","metadata":{"annotations":{},"name":"crontabs.stable.example.com","names...
API Version:  apiextensions.k8s.io/v1beta1
Kind:         CustomResourceDefinition
Metadata:
  Creation Timestamp:  2019-05-09T16:50:55Z
  Generation:          1
  Resource Version:    3193124
  Self Link:           /apis/apiextensions.k8s.io/v1beta1/customresourcedefinitions/crontabs.stable.example.com
  UID:                 9cad2caf-727a-11e9-9fb0-0e8a8b871ace
Spec:
  Additional Printer Columns:
    JSON Path:    .metadata.creationTimestamp
    Description:  CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.

Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    Name:  Age
    Type:  date
  Group:   stable.example.com
  Names:
    Kind:       CronTab
    List Kind:  CronTabList
    Plural:     crontabs
    Short Names:
      ct
    Singular:  crontab
  Scope:       Namespaced
  Version:     v1
  Versions:
    Name:     v1
    Served:   true
    Storage:  true
Status:
  Accepted Names:
    Kind:       CronTab
    List Kind:  CronTabList
    Plural:     crontabs
    Short Names:
      ct
    Singular:  crontab
  Conditions:
    Last Transition Time:  2019-05-09T16:50:55Z
    Message:               no conflicts found
    Reason:                NoConflicts
    Status:                True
    Type:                  NamesAccepted
    Last Transition Time:  <nil>
    Message:               the initial names have been accepted
    Reason:                InitialNamesAccepted
    Status:                True
    Type:                  Established
  Stored Versions:
    v1
Events:  <none>
```
Or we can check the resource directly from the Kubernetes API. First, we start the proxy in one tab of the Cloud9 environment:

```
kubectl proxy --port=8080 --address='0.0.0.0' --disable-filter=true
```

And in another tab we check the existance of the Custom Resource
```
curl -i 127.0.0.1:8080/apis/apiextensions.k8s.io/v1beta1/customresourcedefinitions/crontabs.stable.example.com
```

The response being something like this:
```
HTTP/1.1 200 OK
Audit-Id: ec046098-8373-4c74-8ce7-a6a43951df6e
Content-Length: 2582
Content-Type: application/json
Date: Thu, 09 May 2019 18:07:05 GMT

{
  "kind": "CustomResourceDefinition",
  "apiVersion": "apiextensions.k8s.io/v1beta1",
  "metadata": {
    "name": "crontabs.stable.example.com",
    "selfLink": "/apis/apiextensions.k8s.io/v1beta1/customresourcedefinitions/crontabs.stable.example.com",
    "uid": "24babfb5-7285-11e9-a54d-0615623ca50e",
    "resourceVersion": "3271016",
    "generation": 1,
    "creationTimestamp": "2019-05-09T18:06:18Z",
    "annotations": {
      "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"apiextensions.k8s.io/v1beta1\",\"kind\":\"CustomResourceDefinition\",\"metadata\":{\"annotations\":{},\"name\":\"crontabs.stable.example.com\",\"namespace\":\"\"},\"spec\":{\"group\":\"stable.example.com\",\"names\":{\"kind\":\"CronTab\",\"plural\":\"crontabs\",\"shortNames\":[\"ct\"],\"singular\":\"crontab\"},\"scope\":\"Namespaced\",\"versions\":[{\"name\":\"v1\",\"served\":true,\"storage\":true}]}}\n"
    }
  },
  "spec": {
    "group": "stable.example.com",
    "version": "v1",
    "names": {
      "plural": "crontabs",
      "singular": "crontab",
      "shortNames": [
        "ct"
      ],
      "kind": "CronTab",
      "listKind": "CronTabList"
    },
    "scope": "Namespaced",
    "versions": [
      {
        "name": "v1",
        "served": true,
        "storage": true
      }
    ],
    "additionalPrinterColumns": [
      {
        "name": "Age",
        "type": "date",
        "description": "CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.\n\nPopulated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata",
        "JSONPath": ".metadata.creationTimestamp"
      }
    ]
  },
  "status": {
    "conditions": [
      {
        "type": "NamesAccepted",
        "status": "True",
        "lastTransitionTime": "2019-05-09T18:06:18Z",
        "reason": "NoConflicts",
        "message": "no conflicts found"
      },
      {
        "type": "Established",
        "status": "True",
        "lastTransitionTime": null,
        "reason": "InitialNamesAccepted",
        "message": "the initial names have been accepted"
      }
    ],
    "acceptedNames": {
      "plural": "crontabs",
      "singular": "crontab",
      "shortNames": [
        "ct"
      ],
      "kind": "CronTab",
      "listKind": "CronTabList"
    },
    "storedVersions": [
      "v1"
    ]
  }
}
```
