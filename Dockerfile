FROM jenkins/ssh-agent:latest-alpine-jdk8

RUN apk update && apk add --no-cache curl docker-cli tzdata ansible tar yarn perl

RUN mkdir -p /opt/tools && mkdir -p /opt/workspace

RUN wget https://golang.org/dl/go1.17.2.linux-amd64.tar.gz && \
tar -C /opt/tools -zxf go1.17.2.linux-amd64.tar.gz && \
rm go1.17.2.linux-amd64.tar.gz

RUN wget https://services.gradle.org/distributions/gradle-7.4.1-all.zip && \
unzip -q gradle-7.4.1-all.zip -d /opt/tools/gradle && \
rm gradle-7.4.1-all.zip

RUN wget https://services.gradle.org/distributions/gradle-6.8.3-bin.zip && \
unzip -q gradle-6.8.3-bin.zip -d /opt/tools/gradle && \
rm gradle-6.8.3-bin.zip

RUN wget https://services.gradle.org/distributions/gradle-5.2.1-bin.zip && \
unzip -q gradle-5.2.1-bin.zip -d /opt/tools/gradle && \
rm gradle-5.2.1-bin.zip

RUN ln -s /opt/tools/gradle/gradle-7.4.1 /opt/tools/gradle/latest
ENV GRADLE_HOME=/opt/tools/gradle/latest
ENV GO_HOME=/opt/tools/go
ENV GRADLE7_HOME=/opt/tools/gradle/gradle-7.4.1
ENV GRADLE6_HOME=/opt/tools/gradle/gradle-6.8.3
ENV GRADLE5_HOME=/opt/tools/gradle/gradle-5.2.1

ENV PATH=$GRADLE_HOME/bin:$GO_HOME/bin:$PATH

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


