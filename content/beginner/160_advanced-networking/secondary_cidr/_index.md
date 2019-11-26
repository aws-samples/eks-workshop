---
title: "Using Secondary CIDRs with EKS"
chapter: true
weight: 10
---

# Using Secondary CIDRs with EKS

You can expand your VPC network by adding additional CIDR ranges. This capability can be used if you are running out of IP ranges within your existing VPC or if you have consumed all available RFC 1918 CIDR ranges within your corporate network. EKS supports additional IPv4 CIDR blocks in the 100.64.0.0/10 and 198.19.0.0/16 ranges. You can review this announcement from our [what's new blog](https://aws.amazon.com/about-aws/whats-new/2018/10/amazon-eks-now-supports-additional-vpc-cidr-blocks/)

In this tutorial, we will walk you through the configuration that is needed so that you can launch your Pod networking on top of secondary CIDRs
