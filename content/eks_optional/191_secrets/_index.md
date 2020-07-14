---
title: "Encrypting Secrets with AWS Key Management Service (KMS) Keys"
chapter: true
weight: 191
tags:
  - beginner
---

# Encrypting Kubernetes Secrets

Kubernetes can store secrets that pods can access via a mounted volume. Today, Kubernetes secrets are stored with Base64 encoding, but security teams would prefer a stronger approach. Amazon EKS clusters version 1.13 and higher support the capability of encrypting your Kubernetes secrets using AWS Key Management Service (KMS) Customer Managed Keys (CMK). No changes in the way you are using secrets are required. The only requirement is to enable the encryption provider support during EKS cluster creation.

![kms](/images/eks-secrets-flow-small-1-1024x621.png)


The workflow is as follows:

1. The user (typically in an admin role) creates a secret.
2. The Kubernetes API server in the EKS control plane generates a Data Encryption Key (DEK) locally and uses it to encrypt the plaintext payload in the secret. Note that the control plane generates a unique DEK for every single write, and the plaintext DEK is never saved to disk.
3. The Kubernetes API server calls ```kms:Encrypt``` to encrypt the DEK with the CMK. This key is the root of the key hierarchy, and, in the case of KMS, it creates the CMK on a hardware security module (HSM). In this step, the API server uses the CMK to encrypt the DEK and also caches the base64 of the encrypted DEK.
4. The API server stores the DEK-encrypted secret in etcd.
5. If one now wants to use the secret in, say a pod via a volume (read-path), the reverse process takes place. That is, the API server reads the encrypted secret from etcd and decrypts the secret with the DEK.
6. The application, running in a pod on either EC2 or Fargate, can then consume the secret as usual.