---
title: "AWS KMS and Custom Key Store"
date: 2019-04-09T00:00:00-03:00
weight: 5
draft: false
---


#### Considerations for your AWS KMS CMK

Before we get to the lab exercise, we wanted to take some time to discuss options for generating your AWS KMS CMK. AWS KMS provides you with two alternatives to store your CMK. Your security requirements may dictate which alternative is suitable for your workloads on Amazon EKS. 

##### Custom Key Store (CMK stored within AWS CloudHSM)
For most users, the default AWS KMS key store, which is protected by FIPS 140-2 validated cryptographic modules, fulfills their security requirements.

However, you might consider creating a custom key store if your organization has any of the following requirements:

* The key material cannot be stored in a shared environment.
* The key material must be backed up in multiple AWS Regions.
* The key material must be subject to a secondary, independent audit path.
* The hardware security module (HSM) that generates and stores key material must be certified at [FIPS 140-2 Level 3](https://docs.aws.amazon.com/cloudhsm/latest/userguide/introduction.html).

If any of these requirements apply to you, consider using AWS CloudHSM with AWS KMS to create a [custom key store](https://docs.aws.amazon.com/kms/latest/developerguide/custom-key-store-overview.html).

#### Challenge:
**What level of FIPS 140-2 cryptographic validation does the AWS KMS HSM hold?**

{{%expand "Expand here to see the solution" %}}
The AWS KMS HSMs are validated at Level 2 overall. You can read more about that [here].(https://aws.amazon.com/blogs/security/aws-key-management-service-now-offers-fips-140-2-validated-cryptographic-modules-enabling-easier-adoption-of-the-service-for-regulated-workloads/)

FIPS 140-2 Level 2 validation is sufficient for many use cases, but check with your security and compliance teams to verify.
{{% /expand %}}

{{% notice info %}}
Keep in mind that the KMS Custom Key Store functionality makes use of a minimum of two AWS CloudHSM instances.
{{% /notice %}}

#### Cost
Aside from compliance considerations, your team will want to consider the cost of using this feature. For comparison, I will list the cost of using a CMK created with the default KMS functionality. Then, I will list of the cost of using a CMK created with the custom key store functionality.

##### KMS Standard (Monthly Cost)

- 1 CMK = $1.00
- 90 requests = $0.00 (due to the free tier of 20,000 requests)
- **Total Cost = $1.00**

##### KMS Custom Key Store (Monthly Cost)

- 1 CMK = $1.00
- 90 requests = $0.00 (due to the free tier of 20,000 requests)
- 2 CloudHSM Instances = $2,380.80
- **Total Cost = $2,381.80**

Now that we have discussed AWS KMS support for custom key stores, let's move on to the exercise.