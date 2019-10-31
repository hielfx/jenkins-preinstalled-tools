FROM jenkins/jenkins:latest
LABEL maintainer="Daniel Sánchez Navarro <dansanav@gmail.com>"

ENV KUBE_LATEST_VERSION v.15.0
ENV DANTE_CLI_VERSION v0.0.5
ENV DANTE_CLI_DOWNLOAD_URL https://github.com/jhidalgo3/dante-cli/releases/download/$DANTE_CLI_VERSION/dante-cli-alpine-linux-amd64-$DANTE_CLI_VERSION.tar.gz

# Install apt dependencies
USER root
RUN apt-get update \
  && apt-get install -y \
  ruby \
  make \
  openssl \
  tar \
  gzip \
  python3-pip \
  apt-utils

# Install docker
RUN curl -fsSL https://get.docker.com -o get-docker.sh
RUN sh get-docker.sh
RUN usermod -aG docker jenkins

# Install aws cli
RUN pip3 install awscli --upgrade

# Install kubectl
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl

# Install dante-cli
RUN echo $DANTE_CLI_DOWNLOAD_URL
RUN wget -qO- $DANTE_CLI_DOWNLOAD_URL | tar xvz -C /usr/local/bin

# Drop back to the regular jenkins user - good practice
USER jenkins
