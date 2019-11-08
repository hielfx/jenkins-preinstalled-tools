FROM jenkins/jenkins:latest
LABEL maintainer="Daniel Sánchez Navarro <dansanav@gmail.com>"

ENV GO_VERSION=go1.13.4
ENV NODE_VERSION=12.13.0
ENV NVM_VERSION=v0.35.1
ENV KUBE_LATEST_VERSION=v1.15.0
ENV DANTE_CLI_VERSION=v0.0.5

USER root
# Replace shell with bash so we can source files
RUN mv /bin/sh /bin/_sh && ln -s /bin/bash /bin/sh

# Install apt dependencies
RUN apt-get update \
  && apt-get install -y \
  ruby \
  make \
  openssl \
  tar \
  gzip \
  python3-pip \
  apt-utils

# Install Go
RUN curl -L https://dl.google.com/go/$GO_VERSION.linux-amd64.tar.gz | tar xz -C /usr/local
ENV PATH=/usr/local/go/bin:$PATH

# Install NVM and Nodejs
RUN mkdir -p /var/local/nvm
ENV NVM_DIR=/var/local/nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash \
  && source $NVM_DIR/nvm.sh \
  && nvm install $NODE_VERSION \
  && nvm alias default $NODE_VERSION \
  && nvm use default
ENV NODE_PATH=$NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Install yarn
RUN npm install -g yarn

# Install docker
RUN curl -fsSL https://get.docker.com -o get-docker.sh \
  && sh get-docker.sh \
  &&  usermod -aG docker jenkins

# Install aws cli
RUN pip3 install awscli --upgrade

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$KUBE_LATEST_VERSION/bin/linux/amd64/kubectl \
 && mv kubectl /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl

# Install dante-cli
RUN curl -L https://github.com/hielfx/dante-cli/releases/download/$DANTE_CLI_VERSION/dante-cli-linux-amd64-$DANTE_CLI_VERSION.tar.gz | tar xz -C /usr/local/bin

# Install kubetpl
RUN curl -sSL https://github.com/shyiko/kubetpl/releases/download/0.9.0/kubetpl-0.9.0-$(bash -c '[[ $OSTYPE == darwin* ]] && echo darwin || echo linux')-amd64 -o kubetpl \
  && chmod a+x kubetpl \
  && mv kubetpl /usr/local/bin

# Drop back to the regular jenkins user - good practice
USER jenkins
