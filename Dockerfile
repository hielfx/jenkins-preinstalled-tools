FROM jenkins/jenkins:latest
LABEL maintainer="Daniel Sánchez Navarro <dansanav@gmail.com>"

ENV GO_VERSION=go1.12.9
ENV KUBE_LATEST_VERSION=v1.15.0
ENV DANTE_CLI_VERSION=v0.0.5

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

# Install Go
RUN curl -L https://dl.google.com/go/go1.13.4.linux-amd64.tar.gz | tar xz -C /usr/local
ENV PATH="/usr/local/go/bin:${PATH}"

# Install NVM
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.1/install.sh | bash
RUN echo 'export NVM_DIR="$HOME/.nvm"'                                       >> "$HOME/.bashrc"
RUN echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> "$HOME/.bashrc"
RUN echo '[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion" # This loads nvm bash_completion' >> "$HOME/.bashrc"

# Install nodejs and tools
RUN bash -c 'source $HOME/.nvm/nvm.sh   && \
    nvm install --lts                    && \
    npm install -g yarn && \
    npm install --prefix "$HOME/.nvm/"'

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
