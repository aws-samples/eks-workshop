---
title: "Configure Elasticsearch Access"
date: 2020-07-21T15:48:43-04:00
draft: false
weight: 25
---

### Mapping Roles to Users

Role mapping is the most critical aspect of fine-grained access control. Fine-grained access control has some predefined roles to help you get started, but unless you map roles to users, every request to the cluster ends in a permissions error.

_Backend roles_ offer another way of mapping roles to users. Rather than mapping the same role to dozens of different users, you can map the role to a single backend role, and then make sure that all users have that backend role. Backend roles can be IAM roles or arbitrary strings that you specify when you create users in the internal user database.

We will add the Fluent Bit ARN as a _backend role_ to the _all\_access_ role using the Elasticsearch API

```bash
# We need to retrieve the Fluent Bit Role ARN
export FLUENTBIT_ROLE=$(eksctl get iamserviceaccount --cluster eksworkshop-eksctl --namespace logging -o json | jq '.[].status.roleARN' -r) 

# Get the Elasticsearch Endpoint
export ES_ENDPOINT=$(aws es describe-elasticsearch-domain --domain-name ${ES_DOMAIN_NAME} --output text --query "DomainStatus.Endpoint")

# Update the Elasticsearch internal database
curl -sS -u "${ES_DOMAIN_USER}:${ES_DOMAIN_PASSWORD}" \
    -X PATCH \
    https://${ES_ENDPOINT}/_opendistro/_security/api/rolesmapping/all_access?pretty \
    -H 'Content-Type: application/json' \
    -d'
[
  {
    "op": "add", "path": "/backend_roles", "value": ["'${FLUENTBIT_ROLE}'"]
  }
]
'
```

Output

{{< output >}}
{
  "status" : "OK",
  "message" : "'all_access' updated."
}
{{< /output >}}
