FROM jenkins/jenkins:lts-jdk17

USER root

RUN apt-get update && \
    apt-get install -y \
    wget \
    unzip \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv && \
    . /opt/venv/bin/activate && \
    pip install --upgrade pip && \
    pip install pytest pytest-cov flask flake8 bandit coverage && \
    deactivate
    
 RUN mkdir -p /opt/wiremock && \
     curl -sSl -o /opt/wiremock/wiremock-standalone.jar https://repo1.maven.org/maven2/org/wiremock/wiremock-standalone/3.13.0/wiremock-standalone-3.13.0.jar

 RUN mkdir /opt/wiremock/mappings
 COPY test/wiremock/mappings/. /opt/wiremock/mappings   
 
 RUN mkdir -p /opt/jmeter
 RUN wget https://downloads.apache.org//jmeter/binaries/apache-jmeter-5.6.3.tgz -O /tmp/jmeter.tgz \
    && tar -xzf /tmp/jmeter.tgz -C /opt/jmeter --strip-components=1 \
    && rm /tmp/jmeter.tgz

ENV VIRTUAL_ENV /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"
ENV WIREMOCK_HOME /opt/wiremock
ENV PATH="/opt/wiremock:${PATH}"
ENV PATH="/opt/jmeter/bin:${PATH}"

USER jenkins

RUN jenkins-plugin-cli --plugins \
    workflow-aggregator \
    git \
    blueocean \
    pipeline-utility-steps \
    python \
    ws-cleanup