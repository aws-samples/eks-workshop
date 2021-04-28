---
title: "CodeCommit Repository, Access, and Code"
date: 2018-08-07T08:30:11-07:00
weight: 5
---

We'll start by creating a [CodeCommit](https://aws.amazon.com/codecommit/faqs/) repository to store our example application. This repository will store our application code and `Jenkinsfile`.

```bash
aws codecommit create-repository --repository-name eksworkshop-app
```

We'll create an IAM user with our HTTPS Git credentials for AWS CodeCommit to clone our repository and to push additional commits. This user needs an IAM Policy for access to CodeCommit.

```bash
aws iam create-user \
  --user-name git-user

aws iam attach-user-policy \
  --user-name git-user \
  --policy-arn arn:aws:iam::aws:policy/AWSCodeCommitPowerUser

aws iam create-service-specific-credential \
  --user-name git-user --service-name codecommit.amazonaws.com \
  | tee /tmp/gituser_output.json

GIT_USERNAME=$(cat /tmp/gituser_output.json | jq -r '.ServiceSpecificCredential.ServiceUserName')
GIT_PASSWORD=$(cat /tmp/gituser_output.json | jq -r '.ServiceSpecificCredential.ServicePassword')
CREDENTIAL_ID=$(cat /tmp/gituser_output.json | jq -r '.ServiceSpecificCredential.ServiceSpecificCredentialId')
```

The repository will require some initial code so we'll clone the repository and add a simple Go application.

```bash
sudo pip install git-remote-codecommit

git clone codecommit::${AWS_REGION}://eksworkshop-app
cd eksworkshop-app
```

`server.go` contains our simple application.

```bash
cat << EOF > server.go

package main

import (
    "fmt"
    "net/http"
)

func helloWorld(w http.ResponseWriter, r *http.Request){
    fmt.Fprintf(w, "Hello World")
}

func main() {
    http.HandleFunc("/", helloWorld)
    http.ListenAndServe(":8080", nil)
}
EOF
```

`server_test.go` contains our unit tests.

```bash
cat << EOF > server_test.go

package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func Test_helloWorld(t *testing.T) {
	req, err := http.NewRequest("GET", "http://domain.com/", nil)
	if err != nil {
		t.Fatal(err)
	}

	res := httptest.NewRecorder()
	helloWorld(res, req)

	exp := "Hello World"
	act := res.Body.String()
	if exp != act {
		t.Fatalf("Expected %s got %s", exp, act)
	}
}

EOF
```

The `Jenkinsfile` will contain our pipeline declaration, the additional containers in our build agent pods, and which container will be used for each step of the pipeline.

```bash
cat << EOF > Jenkinsfile
pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: golang
    image: golang:1.13
    command:
    - cat
    tty: true
"""
    }
  }
  stages {
    stage('Run tests') {
      steps {
        container('golang') {
          sh 'go test'
        }
      }
    }
    stage('Build') {
        steps {
            container('golang') {
              sh 'go build -o eksworkshop-app'
              archiveArtifacts "eksworkshop-app"
            }
            
        }
    }
    
  }
}

EOF
```

We'll add the code our code, commit the change, and then push the code to our repository.

```bash
git add --all && git commit -m "Initial commit." && git push
cd ~/environment
```
