---
title: "Inspect the MySQL Request"
date: 2021-5-01T09:00:00-00:00
weight: 24
draft: false
---

From the demo app’s YAML file, we know that the catalog service talks to a MySQL database. Let’s inspect the `catalog` service's mysql requests to see if we can get more information about the type of database connection error.

Select the `px/mysql_data` script from the script drop-down menu. This script shows all of the mysql requests Pixie has traced in the cluster. Let’s filter these requests.

Modify the script’s `start_time` to `-30m` or any window that will include when you [triggered the bug](/intermediate/241_pixie/prereqs/#trigger-the-microservices-application-bug) in the Sock Shop app.

Open the script editor using `ctrl+e` (Windows, Linux) or `cmd+e` (Mac).

On line 34, add the following line to filter the mysql requests to just those with errors:

```bash
    # Filter requests to only include those with an error code.
    df = df[df.resp_status == 3]
```

{{% notice info %}}
Make sure that the new lines just added match the indentation of the existing lines. If not, you will get an `invalid syntax` error when running the script.
{{% /notice %}}

Re-run the script with the RUN button (top right of the page), or using the keyboard shortcut: `ctrl+enter` (Windows, Linux) or `cmd+enter` (Mac).

The output should show one or more requests with errors.

![mysql_request_error](/images/pixie/mysql_request_error.png)

Click on the table row to see the row data in json format.

Scroll down to the `resp_body` json key, and you will see that our error is a SQL syntax error. In particular the `OR` condition was misspelled as `ORR`.

```bash
You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'ORR tag.name=? GROUP BY id ORDER BY ?' at line 1,
```

Congratulations! You've used Pixie to find [the bug](https://github.com/pixie-labs/sock-shop-catalogue/commit/8e627148b72d6c4cbf4d17d08dd60f3bad38961d) in the microservices app!
