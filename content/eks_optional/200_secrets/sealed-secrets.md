---
title: "Sealed Secrets for Kubernetes"
date: 2019-04-09T00:00:00-03:00
weight: 12
draft: false
---

#### How it Works
Sealed Secrets is composed of two parts:
- A cluster-side controller
- A client-side utility called *kubeseal*

Upon startup, the controller looks for a cluster-wide private/public key pair, and generates a new 4096 bit RSA key pair if not found. The private key is persisted in a Secret object in the same namespace as that of the controller. The public key portion of this is made publicly available to anyone wanting to use SealedSecrets with this cluster.

During encryption, each value in the original Secret is symmetrically encrypted using AES-256 with a randomly-generated session key. The session key is then asymmetrically encrypted with the controller's public key using SHA256 and the original Secret's namespace/name as the input parameter. The output of the encryption process is a string that is constructed as follows:  
*length (2 bytes) of  encrypted session key + encrypted session key + encrypted Secret*

When a SealedSecret custom resource is deployed to the Kubernetes cluster, the controller will pick it up, unseal it using the private key and create a Secret resource. During decryption, the SealedSecret's namespace/name is used again as the input parameter. This ensures that the SealedSecret and Secret are strictly tied to the same namespace and name.

The companion CLI tool *kubeseal* is used for creating a SealedSecret custom resource definition (CRD) from a Secret resource definition using the public key. *kubeseal* can communicate with the controller through the Kubernetes API server and retrieve the public key needed for encrypting a Secret at run-time. The public key may also be downloaded from the controller and saved locally to be used offline.