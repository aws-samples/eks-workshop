FROM amazonlinux:2

# Download latest 3.x release of X-Ray daemon and AWS CLI 2
RUN yum install -y unzip && \
    cd /tmp/ && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    curl https://s3.dualstack.us-east-2.amazonaws.com/aws-xray-assets.us-east-2/xray-daemon/aws-xray-daemon-linux-3.x.zip > aws-xray-daemon-linux-3.x.zip && \
    unzip aws-xray-daemon-linux-3.x.zip && \
    cp xray /usr/bin/xray && \
    rm aws-xray-daemon-linux-3.x.zip && \
    rm awscliv2.zip && \
    rm cfg.yaml

EXPOSE 2000/udp

ENTRYPOINT ["/usr/bin/xray"]

# No cmd line parameters, use default configuration
CMD ['']
