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
apiVersion: apiextensions.k8s.io/v1
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
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                cronSpec:
                  type: string
                image:
                  type: string
                replicas:
                  type: integer
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
crontabs.stable.example.com   2022-07-15T12:09:41Z
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
Annotations:  <none>
API Version:  apiextensions.k8s.io/v1
Kind:         CustomResourceDefinition
Metadata:
  Creation Timestamp:  2022-07-15T12:09:41Z
  Generation:          1
  Managed Fields:
    API Version:  apiextensions.k8s.io/v1
    Fields Type:  FieldsV1
    Manager:      kube-apiserver
    Operation:    Update
    Time:         2022-07-15T12:09:41Z
    API Version:  apiextensions.k8s.io/v1
    Manager:         kubectl-client-side-apply
    Operation:       Update
    Time:            2022-07-15T12:09:41Z
  Resource Version:  821325
  UID:               c2184050-1a8d-4945-9bd2-722d14d9d0fa
Spec:
  Conversion:
    Strategy:  None
  Group:       stable.example.com
  Names:
    Kind:       CronTab
    List Kind:  CronTabList
    Plural:     crontabs
    Short Names:
      ct
    Singular:  crontab
  Scope:       Namespaced
  Versions:
    Name:  v1
    Schema:
      openAPIV3Schema:
        Properties:
          Spec:
            Properties:
              Cron Spec:
                Type:  string
              Image:
                Type:  string
              Replicas:
                Type:  integer
            Type:      object
        Type:          object
    Served:            true
    Storage:           true
Status:
  Accepted Names:
    Kind:       CronTab
    List Kind:  CronTabList
    Plural:     crontabs
    Short Names:
      ct
    Singular:  crontab
  Conditions:
    Last Transition Time:  2022-07-15T12:09:41Z
    Message:               no conflicts found
    Reason:                NoConflicts
    Status:                True
    Type:                  NamesAccepted
    Last Transition Time:  2022-07-15T12:09:41Z
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
Audit-Id: 20146bde-910d-4c82-ab01-609225e4d262
Cache-Control: no-cache, private
Content-Length: 3650
Content-Type: application/json
Date: Fri, 15 Jul 2022 12:47:07 GMT
Warning: 299 - "apiextensions.k8s.io/v1beta1 CustomResourceDefinition is deprecated in v1.16+, unavailable in v1.22+; use apiextensions.k8s.io/v1 CustomResourceDefinition"
X-Kubernetes-Pf-Flowschema-Uid: 16b0834b-6ac6-4b7e-8b43-505208a6efc8
X-Kubernetes-Pf-Prioritylevel-Uid: f3c0805c-6d2b-493b-a958-724b2adeb80b

{
  "kind": "CustomResourceDefinition",
  "apiVersion": "apiextensions.k8s.io/v1beta1",
  "metadata": {
    "name": "crontabs.stable.example.com",
    "uid": "c2184050-1a8d-4945-9bd2-722d14d9d0fa",
    "resourceVersion": "821325",
    "generation": 1,
    "creationTimestamp": "2022-07-15T12:09:41Z",
    "annotations": {
      "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"apiextensions.k8s.io/v1\",\"kind\":\"CustomResourceDefinition\",\"metadata\":{\"annotations\":{},\"name\":\"crontabs.stable.example.com\"},\"spec\":{\"group\":\"stable.example.com\",\"names\":{\"kind\":\"CronTab\",\"plural\":\"crontabs\",\"shortNames\":[\"ct\"],\"singular\":\"crontab\"},\"scope\":\"Namespaced\",\"versions\":[{\"name\":\"v1\",\"schema\":{\"openAPIV3Schema\":{\"properties\":{\"spec\":{\"properties\":{\"cronSpec\":{\"type\":\"string\"},\"image\":{\"type\":\"string\"},\"replicas\":{\"type\":\"integer\"}},\"type\":\"object\"}},\"type\":\"object\"}},\"served\":true,\"storage\":true}]}}\n"
    },
    "managedFields": [
      {
        "manager": "kube-apiserver",
        "operation": "Update",
        "apiVersion": "apiextensions.k8s.io/v1",
        "time": "2022-07-15T12:09:41Z",
        "fieldsType": "FieldsV1",
        "fieldsV1": {"f:status":{"f:acceptedNames":{"f:kind":{},"f:listKind":{},"f:plural":{},"f:shortNames":{},"f:singular":{}},"f:conditions":{"k:{\"type\":\"Established\"}":{".":{},"f:lastTransitionTime":{},"f:message":{},"f:reason":{},"f:status":{},"f:type":{}},"k:{\"type\":\"NamesAccepted\"}":{".":{},"f:lastTransitionTime":{},"f:message":{},"f:reason":{},"f:status":{},"f:type":{}}}}}
      },
      {
        "manager": "kubectl-client-side-apply",
        "operation": "Update",
        "apiVersion": "apiextensions.k8s.io/v1",
        "time": "2022-07-15T12:09:41Z",
        "fieldsType": "FieldsV1",
        "fieldsV1": {"f:metadata":{"f:annotations":{".":{},"f:kubectl.kubernetes.io/last-applied-configuration":{}}},"f:spec":{"f:conversion":{".":{},"f:strategy":{}},"f:group":{},"f:names":{"f:kind":{},"f:listKind":{},"f:plural":{},"f:shortNames":{},"f:singular":{}},"f:scope":{},"f:versions":{}}}
      }
    ]
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
    "validation": {
      "openAPIV3Schema": {
        "type": "object",
        "properties": {
          "spec": {
  "type": "object",
  "properties": {
    "cronSpec": {
  "type": "string"
},
    "image": {
  "type": "string"
},
    "replicas": {
  "type": "integer"
}
  }
}
        }
      }
    },
    "versions": [
      {
        "name": "v1",
        "served": true,
        "storage": true
      }
    ],
    "conversion": {
      "strategy": "None"
    },
    "preserveUnknownFields": false
  },
  "status": {
    "conditions": [
      {
        "type": "NamesAccepted",
        "status": "True",
        "lastTransitionTime": "2022-07-15T12:09:41Z",
        "reason": "NoConflicts",
        "message": "no conflicts found"
      },
      {
        "type": "Established",
        "status": "True",
        "lastTransitionTime": "2022-07-15T12:09:41Z",
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
