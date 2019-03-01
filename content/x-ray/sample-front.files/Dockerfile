# This is a multi-stage build. First we are going to compile and then
# create a small image for runtime.
FROM golang:1.11.1 as builder

RUN mkdir -p /go/src/github.com/eks-workshop-x-ray-sample-front
WORKDIR /go/src/github.com/eks-workshop-x-ray-sample-front
RUN useradd -u 10001 app
ENV GO111MODULE on
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -ldflags '-extldflags "-static"' .

FROM scratch

COPY --from=builder /go/src/github.com/eks-workshop-x-ray-sample-front/sample-front /main
COPY --from=builder /etc/passwd /etc/passwd
USER app

EXPOSE 8080
CMD ["/main"]
