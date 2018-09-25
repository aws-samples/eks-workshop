Setting up infrastructure:

1. ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text); aws s3 mb --region us-east-1 s3://${ACCOUNT_ID}-us-east-1-eksworkshop.com-terraform-state-store
1. go to https://console.aws.amazon.com/codebuild/home?region=us-east-1#/projects/create (assuming region is us-east-1)
and click "connect to github" -- If necessary authenticate to github allowing codebuild access to your github repos.
(there is apparently no other way to make this happen, according to the codebuild docs). You don't need to do anything further,
and don't need to complete creating a codebuild project via the console.

1. *terraform init* Initialize and get terraform modules
1. *terraform plan -lock=false* see what will be created
1. *terraform apply -lock=false* create resources
1. *this will eventually break, waiting on ACM to issue your certificate. Once that happens, continue*
1. *terraform init --force-copy* copy state to s3 backend
1. *terraform apply* to complete setup

If you need to revert back to local terraform state:
1. comment out the backend module
1. run *terraform init*
1. answer *yes* to copying state from s3

TODO: automate the lambda installation
