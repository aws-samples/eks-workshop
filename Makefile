.PHONY: build theme drafts server test deploy deploycontent deploytemplates deployothers clean

build: theme
	hugo -v

theme:
	git submodule init && git submodule update

drafts:
	hugo server -w -v -DF --disableFastRender --enableGitInfo --bind=0.0.0.0

server:
	hugo server -w -v --enableGitInfo --bind=0.0.0.0 --port 8080 --navigateToChanged

test: build
	docker run -v ${PWD}/public/:/public 18fgsa/html-proofer /public --empty-alt-ignore --allow-hash-href --log-level ':debug'

deploy:
	aws s3 sync public/ s3://us-east-1-eksworkshop.com/ --delete

deploycontent:
	aws s3 sync public/ s3://us-east-1-eksworkshop.com/ --delete --cache-control "max-age=3600, public" --exclude "*" --include "*.html" --include "*.xml"

deploytemplates:
	aws s3 sync templates/ s3://${TEMPLATE_BUCKET}/templates/${CODEBUILD_GIT_CLEAN_BRANCH}/ --delete --acl public-read --cache-control "max-age=86400, public"

deployothers:
	aws s3 sync public/ s3://us-east-1-eksworkshop.com/ --delete --cache-control "max-age=86400, public" --exclude "*.html" --exclude "*.xml"

clean:
	rm -rf public