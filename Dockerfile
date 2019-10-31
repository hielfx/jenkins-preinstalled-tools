FROM jenkins/jenkins:lts
# Install apt dependencies
USER root
RUN apt-get update \
  && apt-get install -y \
  ruby \
  make
# drop back to the regular jenkins user - good practice
USER jenkins
