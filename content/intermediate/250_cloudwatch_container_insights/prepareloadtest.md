---
title: "Preparing your Load Test"
chapter: false
weight: 7
---


#### Preparing your Load Test 


Now that we have monitoring enabled we will simulate heavy load to our EKS Cluster hosting our Wordpress install. While generating the load, we can watch CloudWatch Container Insights for the performance metrics. 

##### Install Siege for load testing on your Workspace:

Download Siege by running the below command in your Cloud9 terminal.

```
curl -C - -O http://download.joedog.org/siege/siege-latest.tar.gz
```

Once downloaded we’ll extract this file and change to the extracted directory. The version may change but you can see the directory name created via the output of the tar command.

```
tar -xvf siege-latest.tar.gz
```

![alt text](/images/ekscwci/siegeextract.png "Extract Siege")


```
cd siege-4.0.4
```
(change for version installed)

Once in the directory we’ll need to make and install the Siege application. 
```
./configure
make all
sudo make install 
```
Verify Siege is working by typing the below into your terminal window.

```
siege --version
```
![alt text](/images/ekscwci/siegeversion.png "Siege Version Info")



