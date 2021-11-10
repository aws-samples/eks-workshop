---
title: "AWS KMS and Custom Key Store"
date: 2021-11-10T00:00:00-03:00
weight: 5
pre: '<i class="fa fa-film" aria-hidden="true"></i>'
draft: false
---


#### Considerations for your AWS KMS CMK

Before we get to the lab exercise, we wanted to take some time to discuss options for generating your AWS KMS CMK. AWS KMS provides you with two alternatives to store your CMK. Your security requirements may dictate which alternative is suitable for your workloads on Amazon EKS.

{{% notice info %}}
There is an [AWS Online Tech Talk on *Encrypting Secrets in Amazon EKS*](https://pages.awscloud.com/Encrypting-Secrets-in-Amazon-EKS_2020_0502-CON_OD.html?&trk=ep_card-el_a131L0000084iG3QAI&trkCampaign=NA-FY20-AWS-DIGMKT-WEBINAR-SERIES-May_2020_0502-CON&sc_channel=el&sc_campaign=pac_2018-2019_exlinks_ondemand_OTT_evergreen&sc_outcome=Product_Adoption_Campaigns&sc_geo=NAMER&sc_country=mult) that dives deep into this topic.
{{% /notice %}}

{{< youtube d21JrnszG7Y >}}

##### Custom Key Store (CMK stored within AWS CloudHSM)

For most users, the default AWS KMS key store, which is protected by FIPS 140-2 validated cryptographic modules, fulfills their security requirements.

However, you might consider creating a custom key store if your organization has any of the following requirements:

* The key material cannot be stored in a shared environment.
* The key material must be subject to a secondary, independent audit path.
* The hardware security module (HSM) that generates and stores key material must be certified at [FIPS 140-2 Level 3](https://docs.aws.amazon.com/cloudhsm/latest/userguide/introduction.html).

If any of these requirements apply to you, consider using AWS CloudHSM with AWS KMS to create a [custom key store](https://docs.aws.amazon.com/kms/latest/developerguide/custom-key-store-overview.html).

#### Challenge

**What level of FIPS 140-2 cryptographic validation does the AWS KMS HSM hold?**

{{%expand "Expand here to see the solution" %}}
The AWS KMS HSMs are validated at Level 2 overall. You can read more about the topic [in this blog post](https://aws.amazon.com/blogs/security/aws-key-management-service-now-offers-fips-140-2-validated-cryptographic-modules-enabling-easier-adoption-of-the-service-for-regulated-workloads/).

{{% /expand %}}

{{% notice info %}}
Keep in mind that the KMS Custom Key Store functionality makes use of a minimum of two AWS CloudHSM instances.
{{% /notice %}}

#### Cost

Aside from compliance and security requirements, you may want to consider the cost of using custom key stores. Below you can find a cost comparison between default AWS KMS key store and AWS KMS custom key store for the N. Virginia AWS region (us-east-1). You can find the latest KMS pricing information [here](https://aws.amazon.com/kms/pricing/).

##### KMS Default (Monthly Cost)

- 1 CMK = $1.00
- 100 requests = $0.00 (free tier of 20,000 requests/month)
- **Total Cost = $1.00**

##### KMS Custom Key Store (Monthly Cost)

- 1 CMK = $1.00
- 100 requests = $0.00 (free tier of 20,000 requests/month)
- 2 CloudHSM Instances = $2,380.80
- **Total Cost = $2,381.80**

Now that we have discussed AWS KMS support for custom key stores, let's move on to the exercise.
