FROM jenkins/ssh-agent:latest-alpine-jdk8

RUN apk update && apk add --no-cache curl docker-cli tzdata ansible tar yarn perl openjdk11 git

ENV JAVA_HOME=/usr/lib/jvm/default-jvm/jre

ENV JENKINS_AGENT_HOME=/root

ARG TOOLS_HOME=/opt/tools

RUN mkdir -p $TOOLS_HOME/gradle && mkdir -p /opt/workspace

RUN wget https://golang.org/dl/go1.17.2.linux-amd64.tar.gz && \
tar -C $TOOLS_HOME -zxf go1.17.2.linux-amd64.tar.gz && \
rm go1.17.2.linux-amd64.tar.gz

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

ENV GROOVY_HOME /opt/tools/groovy

ENV GROOVY_VERSION 4.0.2
RUN set -o errexit -o nounset \
    && echo "Installing build dependencies" \
    && apk add --no-cache --virtual .build-deps \
        gnupg \
    \
    && echo "Downloading Groovy" \
    && wget --no-verbose --output-document=groovy.zip "https://archive.apache.org/dist/groovy/${GROOVY_VERSION}/distribution/apache-groovy-binary-${GROOVY_VERSION}.zip" \
    \
    && echo "Importing keys listed in http://www.apache.org/dist/groovy/KEYS from key server" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --batch --no-tty --keyserver keyserver.ubuntu.com --recv-keys \
        7FAA0F2206DE228F0DB01AD741321490758AAD6F \
        331224E1D7BE883D16E8A685825C06C827AF6B66 \
        34441E504A937F43EB0DAEF96A65176A0FB1CD0B \
        9A810E3B766E089FFB27C70F11B595CEDC4AEBB5 \
        81CABC23EECA0790E8989B361FF96E10F0E13706 \
    \
    && echo "Checking download signature" \
    && wget --no-verbose --output-document=groovy.zip.asc "https://archive.apache.org/dist/groovy/${GROOVY_VERSION}/distribution/apache-groovy-binary-${GROOVY_VERSION}.zip.asc" \
    && gpg --batch --no-tty --verify groovy.zip.asc groovy.zip \
    && rm -rf "${GNUPGHOME}" \
    && rm groovy.zip.asc \
    \
    && echo "Cleaning up build dependencies" \
    && apk del .build-deps \
    \
    && echo "Installing Groovy" \
    && unzip groovy.zip \
    && rm groovy.zip \
    && mv "groovy-${GROOVY_VERSION}" "${GROOVY_HOME}/" \
    && ln -s "${GROOVY_HOME}/bin/grape" /usr/bin/grape \
    && ln -s "${GROOVY_HOME}/bin/groovy" /usr/bin/groovy \
    && ln -s "${GROOVY_HOME}/bin/groovyc" /usr/bin/groovyc \
    && ln -s "${GROOVY_HOME}/bin/groovyConsole" /usr/bin/groovyConsole \
    && ln -s "${GROOVY_HOME}/bin/groovydoc" /usr/bin/groovydoc \
    && ln -s "${GROOVY_HOME}/bin/groovysh" /usr/bin/groovysh \
    && ln -s "${GROOVY_HOME}/bin/java2groovy" /usr/bin/java2groovy \
    \
    && echo "Editing startGroovy to include java.xml.bind module" \
    && sed --in-place 's|startGroovy ( ) {|startGroovy ( ) {\n    JAVA_OPTS="$JAVA_OPTS --add-modules=ALL-SYSTEM"|' "${GROOVY_HOME}/bin/startGroovy"


RUN set -o errexit -o nounset \
    && echo "Testing Groovy installation" \
    && groovy --version

ENV PATH=$GRADLE_HOME/bin:$GO_HOME/bin:$JAVA_HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$GROOVY_HOME/bin

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
