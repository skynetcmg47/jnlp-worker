FROM jenkins/jnlp-agent-alpine:latest

RUN apk update && apk add --no-cache curl docker-cli tzdata openssh

RUN mkdir -p /home/jenkins/tools && mkdir -p /home/jenkins/workspace

RUN wget https://golang.org/dl/go1.17.2.linux-amd64.tar.gz && \
tar -C /home/jenkins/tools -zxf go1.17.2.linux-amd64.tar.gz && \
rm go1.17.2.linux-amd64.tar.gz

RUN wget https://services.gradle.org/distributions/gradle-7.4.1-all.zip && \
unzip -q gradle-7.4.1-all.zip -d /home/jenkins/tools/gradle && \
rm gradle-7.4.1-all.zip

RUN wget https://services.gradle.org/distributions/gradle-6.8.3-bin.zip && \
unzip -q gradle-6.8.3-bin.zip -d /home/jenkins/tools/gradle && \
rm gradle-6.8.3-bin.zip

RUN wget https://services.gradle.org/distributions/gradle-5.2.1-bin.zip && \
unzip -q gradle-5.2.1-bin.zip -d /home/jenkins/tools/gradle && \
rm gradle-5.2.1-bin.zip

RUN ln -s /home/jenkins/tools/gradle/gradle-7.4.1 /home/jenkins/tools/gradle/latest
ENV GRADLE_HOME=/home/jenkins/tools/gradle/latest
ENV GO_HOME=/home/jenkins/tools/go
ENV GRADLE7_HOME=/home/jenkins/tools/gradle/gradle-7.4.1
ENV GRADLE6_HOME=/home/jenkins/tools/gradle/gradle-6.8.3
ENV GRADLE5_HOME=/home/jenkins/tools/gradle/gradle-5.2.1

ENV PATH=$GRADLE_HOME/bin:$GO_HOME/bin:$PATH

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


