FROM jenkins/jenkins:lts
# Install apt dependencies
USER root
RUN apt-get update \
  && apt-get install -y \
  ruby \
  make
# Install docker
RUN curl -fsSL https://get.docker.com -o get-docker.sh
RUN sh get-docker.sh
RUN usermod -aG docker jenkins
RUN systemctl enable docker
# drop back to the regular jenkins user - good practice
USER jenkins
