---
title: "Running the Load Test"
chapter: false
weight: 8
---

#### Run Siege to Load Test your Wordpress Site

Now that Siege has been installed, we're going to generate some load to our Wordpress site and see the metrics change in CloudWatch Container Insights.

From your terminal window, run the following command.

```bash
export WP_ELB=$(kubectl -n wordpress-cwi get svc understood-zebu-wordpress -o jsonpath="{.status.loadBalancer.ingress[].hostname}")

siege -q -t 15S -c 200 -i http://${WP_ELB}
```

This command tells Siege to run 200 concurrent connections to your Wordpress site at varying URLS for 15 seconds.

After the 15 seconds, you should see an output like the one below.

{{< output >}}
Lifting the server siege...      done.

Transactions:                    614 hits
Availability:                 100.00 %
Elapsed time:                  14.33 secs
Data transferred:               4.14 MB
Response time:                  3.38 secs
Transaction rate:              42.85 trans/sec
Throughput:                     0.29 MB/sec
Concurrency:                  144.79
Successful transactions:         614
Failed transactions:               0
Longest transaction:            5.55
Shortest transaction:           0.19
 
FILE: /home/ec2-user/siege.log
You can disable this annoying message by editing
the .siegerc file in your home directory; change
the directive 'show-logfile' to false.
{{< /output >}}

### Now let's go view our newly collected metrics!
