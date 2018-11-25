#!/bin/bash

TAG=$(git log -1 --pretty=%H)

REPOSITORY=rnzdocker1/eks-workshop-x-ray-sample-back

docker build --tag $REPOSITORY:$TAG .

docker push $REPOSITORY:$TAG
