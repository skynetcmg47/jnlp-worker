FROM jenkins/ssh-agent:latest-alpine-jdk8

RUN apk update && apk add --no-cache curl docker-cli tzdata ansible tar yarn perl openjdk11 git unzip

ENV JAVA_HOME=/usr/lib/jvm/default-jvm/jre

ENV JENKINS_AGENT_HOME=/root

ARG TOOLS_HOME=/opt/tools

RUN mkdir -p $TOOLS_HOME/gradle && mkdir -p /opt/workspace

RUN wget https://golang.org/dl/go1.18.4.linux-amd64.tar.gz && \
tar -C $TOOLS_HOME -zxf go1.18.4.linux-amd64.tar.gz && \
rm go1.18.4.linux-amd64.tar.gz

RUN wget https://services.gradle.org/distributions/gradle-7.4.1-all.zip && \
unzip -q gradle-7.4.1-all.zip -d $TOOLS_HOME/gradle && \
rm gradle-7.4.1-all.zip

RUN wget https://services.gradle.org/distributions/gradle-6.8.3-bin.zip && \
unzip -q gradle-6.8.3-bin.zip -d $TOOLS_HOME/gradle && \
rm gradle-6.8.3-bin.zip

RUN wget https://services.gradle.org/distributions/gradle-5.2.1-bin.zip && \
unzip -q gradle-5.2.1-bin.zip -d $TOOLS_HOME/gradle && \
rm gradle-5.2.1-bin.zip

RUN ln -s $TOOLS_HOME/gradle/gradle-7.4.1 $TOOLS_HOME/gradle/latest
ENV GRADLE_HOME=$TOOLS_HOME/gradle/latest
ENV GO_HOME=$TOOLS_HOME/go
ENV GRADLE7_HOME=$TOOLS_HOME/gradle/gradle-7.4.1
ENV GRADLE6_HOME=$TOOLS_HOME/gradle/gradle-6.8.3
ENV GRADLE5_HOME=$TOOLS_HOME/gradle/gradle-5.2.1

ENV PATH=$GRADLE_HOME/bin:$GO_HOME/bin:$JAVA_HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN mkdir -p /root/.ssh \
    && chmod 0700 /root/.ssh \
    && passwd -u root \
    && apk add openrc \
    && echo -e "PasswordAuthentication no" >> /etc/ssh/sshd_config \
    && sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config \
    && mkdir -p /run/openrc \
    && touch /run/openrc/softlevel
ENTRYPOINT ["sh", "-c", "rc-status; rc-service sshd start; setup-sshd"]
