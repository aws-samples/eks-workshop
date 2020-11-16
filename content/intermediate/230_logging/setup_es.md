---
title: "Provision an Elasticsearch Cluster"
date: 2018-08-07T08:30:11-07:00
weight: 20
---

This example creates an one instance Amazon Elasticsearch cluster named eksworkshop-logging. This cluster will be created in the same region as the EKS Kubernetes cluster.

The Elasticsearch cluster will have [Fine-Grained Access Control](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/fgac.html) enabled.

[Fine-grained access control](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/fgac.html) offers two forms of authentication and authorization:

* A built-in user database, which makes it easy to configure usernames and passwords inside of Elasticsearch.
* AWS Identity and Access Management (IAM) integration, which lets you map IAM principals to permissions.

We will create a public access domain with fine-grained access control enabled, an access policy that doesn't use IAM principals, and a master user in the internal user database.

First let's create some variables

```bash
# name of our elasticsearch cluster
export ES_DOMAIN_NAME="eksworkshop-logging"

# Elasticsearch version
export ES_VERSION="7.4"

# kibana admin user
export ES_DOMAIN_USER="eksworkshop"

# kibana admin password
export ES_DOMAIN_PASSWORD="$(openssl rand -base64 12)_Ek1$"
```

We are ready to create the Elasticsearch cluster

```bash
# Download and update the template using the variables created previously
curl -sS https://www.eksworkshop.com/intermediate/230_logging/deploy.files/es_domain.json \
  | envsubst > ~/environment/logging/es_domain.json

# Create the cluster
aws es create-elasticsearch-domain \
  --cli-input-json  file://~/environment/logging/es_domain.json
```

{{% notice info %}}
It takes a little while for the cluster to be in an active state. The AWS Console should show the following status when the cluster is ready.
{{% /notice %}}

![Elasticsearch Dashboard](/images/logging/logging_es_dashboard.png)

You could also check this via AWS CLI

```bash
if [ $(aws es describe-elasticsearch-domain --domain-name ${ES_DOMAIN_NAME} --query 'DomainStatus.Processing') == "false" ]
  then
    tput setaf 2; echo "The Elasticsearch cluster is ready"
  else
    tput setaf 1;echo "The Elasticsearch cluster is NOT ready"
fi
```

{{% notice warning %}}
It is important to wait for the cluster to be available before moving to the next section.
{{% /notice %}}
