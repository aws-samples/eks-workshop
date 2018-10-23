master branch: ![Build Status](https://codebuild.us-east-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiUmYrQzlvK2JVYWloK3N5NFh5WUZNS1duYUtVeFN2eWJLNk9VdU9NdzdDdGtobldPcHBKYjdVQ0YxV0NQLzRZeXhWbkJVTkc2Ymd2TEpJblNYb1BraXFNPSIsIml2UGFyYW1ldGVyU3BlYyI6IjRObVVDcVUyb3JJUEFYQTciLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)

jenkinsworld branch: ![Build Status](https://codebuild.us-east-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiUmYrQzlvK2JVYWloK3N5NFh5WUZNS1duYUtVeFN2eWJLNk9VdU9NdzdDdGtobldPcHBKYjdVQ0YxV0NQLzRZeXhWbkJVTkc2Ymd2TEpJblNYb1BraXFNPSIsIml2UGFyYW1ldGVyU3BlYyI6IjRObVVDcVUyb3JJUEFYQTciLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=jenkinsworld)

tigera branch: ![Build Status](https://codebuild.us-east-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiUmYrQzlvK2JVYWloK3N5NFh5WUZNS1duYUtVeFN2eWJLNk9VdU9NdzdDdGtobldPcHBKYjdVQ0YxV0NQLzRZeXhWbkJVTkc2Ymd2TEpJblNYb1BraXFNPSIsIml2UGFyYW1ldGVyU3BlYyI6IjRObVVDcVUyb3JJUEFYQTciLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=tigera)

# eksworkshop

### Setup:

#### Install Hugo:
On a mac:

`brew install hugo`

On Linux:
  - Download from the releases page: https://github.com/gohugoio/hugo/releases/tag/v0.46
  - Extract and save the executable to `/usr/local/bin`

#### Clone this repo:
From wherever you checkout repos:
`git clone git@github.com:aws-samples/eks-workshop.git` (or your fork)

#### Clone the theme submodule:
`cd eksworkshop`

`git submodule init` ;
`git submodule update`

#### Install Node.js and npm:
You can follow instructions from npm website: https://www.npmjs.com/get-npm

#### Install node packages:
`npm install`

#### Run Hugo locally:
`npm run server`
or
`npm run drafts` to see stubbed in draft pages.

`npm run build` will build your content locally and output to `./public/`

`npm run test` will test the built content for bad links

#### View Hugo locally:
Visit http://localhost:1313/ to see the site.

#### Making Edits:
As you save edits to a page, the site will live-reload to show your changes.

#### Auto Deploy:
Any commits to master will auto build and deploy in a couple of minutes. You can see the currently
deployed hash at the bottom of the menu panel.

Any commits to a branch will auto build and deploy in a couple of minutes to a custom route named with the branch name. You can see the currently
deployed hash at the bottom of the menu panel.
An example is the "jenkinsworld" branch would be deployed to https://eksworkshop.com/jenkinsworld/

note: shift-reload may be necessary in your browser to reflect the latest changes.

