---
title: "Accessing Wordpress"
chapter: false
weight: 3
---

Once you have your URL, you can try and Login with the following credentials to see your blog and make sure it’s working. You’ll need your username and password so run the following command to get those. 


```
echo Username: user
echo Password: $(kubectl get secret --namespace default understood-zebu-wordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)
```

![alt text](/images/ekscwci/wplogin.png "WP Login")



In your favorite browser paste in your Wordpress Admin URL from the Installing Wordpress section.  You should be greeted with the following screen.
![alt text](/images/ekscwci/wploginpage.png "WP Login")



Enter your username and password to make sure they work. 

If you are taken to the below screen, you have a successfully running Wordpress install backed by MaiaDB in your EKS Cluster. 
![alt text](/images/ekscwci/wpdashboard.png "Wordpress Dashboard")


Now that we have verified that the site is working we can continue with getting CloudWatch Container Insights installed on our cluster! 

