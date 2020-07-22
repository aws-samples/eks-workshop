---
title: "...ON YOUR OWN - Validate Workspace Role"
chapter: false
disableToc: true
hidden: true
---


The output assumed-role name should contain:
```
eksworkshop-admin
```

#### VALID

If the _Arn_ contains the role name from above and an Instance ID, you may proceed.

```output
{
    "Account": "123456789012", 
    "UserId": "AROA1SAMPLEAWSIAMROLE:i-01234567890abcdef", 
    "Arn": "arn:aws:sts::123456789012:assumed-role/eksworkshop-admin/i-01234567890abcdef"
}
```