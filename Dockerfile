FROM jenkins/ssh-agent:5.16.0-alpine-jdk11
RUN apk update && apk add --no-cache curl docker-cli tzdata ansible tar yarn perl git zip rsync jq coreutils sudo curl-dev docker-cli-buildx
ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools yq==2.14.0 ansi2html
RUN python -m pip install awscli 

ENV JENKINS_AGENT_HOME=/home/jenkins

ARG TOOLS_HOME=/opt/tools

RUN mkdir -p $TOOLS_HOME/gradle && mkdir -p /opt/workspace


ENV PATH=$JAVA_HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


RUN mkdir -p $JENKINS_AGENT_HOME/.ssh \
    && chmod 0700 $JENKINS_AGENT_HOME/.ssh \
    && apk add openrc \
    && echo -e "PasswordAuthentication no" >> /etc/ssh/sshd_config \
    && sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config \
    && mkdir -p /run/openrc \
    && touch /run/openrc/softlevel

COPY setup-sshd /usr/local/bin/setup-sshd
COPY ssh-config /home/jenkins/.ssh/config


RUN mkdir -p /etc/sudoers.d \
    && echo "jenkins ALL=(root) NOPASSWD: /usr/local/bin/setup-sshd" > /etc/sudoers.d/jenkins \
    && echo "jenkins ALL=(root) NOPASSWD: /usr/bin/tee" >> /etc/sudoers.d/jenkins \
    && chmod 0440 /etc/sudoers.d/jenkins
USER jenkins
ENTRYPOINT ["sh", "-c", "env | grep _ | sudo tee -a /etc/environment; sudo setup-sshd"]
