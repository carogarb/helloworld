FROM jenkins/jenkins:lts-jdk17

USER root

RUN apt-get update && \
    apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv && \
    . /opt/venv/bin/activate && \
    pip install --upgrade pip && \
    pip install flask pytest && \
    deactivate
    
 RUN mkdir -p /opt/wiremock && \
     curl -sSl -o /opt/wiremock/wiremock-standalone.jar https://repo1.maven.org/maven2/org/wiremock/wiremock-standalone/3.13.0/wiremock-standalone-3.13.0.jar

 RUN mkdir /opt/wiremock/mappings
 COPY test/wiremock/mappings/. /opt/wiremock/mappings    

ENV VIRTUAL_ENV /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"
ENV WIREMOCK_HOME /opt/wiremock
ENV PATH="/opt/wiremock:${PATH}"

USER jenkins

RUN jenkins-plugin-cli --plugins \
    workflow-aggregator \
    git \
    blueocean \
    pipeline-utility-steps \
    python \
    ws-cleanup