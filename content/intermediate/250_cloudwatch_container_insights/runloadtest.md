
---
title: "Running the Load Test"
chapter: false
weight: 8
---


#### Run Siege to Load Test your Wordpress Site:

Now that Siege is setup and running, we're going to generate some load to our Wordpress site.  With that load we can see the metrics change in CloudWatch Container Insights.

From your terminal window in the Siege directory, run the following command.

```
siege -c 200 -i {YOURLOADBALANCER URL}
```

<div data-proofer-ignore>
*i.e. siege -c 200 -i http://a2d693dc5fbf411e9a4f202f7f69e9b7-1672154051.us-east-2.elb.amazonaws.com/index.php*
</div>

This command tells Siege to run 200 concurrent connections to your Wordpress site at varying URLS. You should see an output like the below. At first it will show connections to the root of your site, and then you should start to see it jump around to various URLS of your site. 

Let this test run for 15-20 seconds then you can kill it with ctrl+c in your terminal window. You can let it run for longer but within about 30 seconds you'll max the open connections of the cluster and it will terminate itself. 

![alt text](/images/ekscwci/siegerun.png "Run Siege")


### Now let's go view our newly collected metrics! 

