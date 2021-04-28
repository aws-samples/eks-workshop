#!/bin/bash

TAG=$(git log -1 --pretty=%H)

REPOSITORY=trevorrobertsjr/eks-workshop-x-ray-daemon

docker build --tag $REPOSITORY:$TAG .

docker push $REPOSITORY:$TAG
