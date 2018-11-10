# This dockerfile builds the zap stable release
FROM registry.access.redhat.com/openshift3/jenkins-slave-base-rhel7
MAINTAINER Deven Phillips <deven.phillips@redhat.com>

USER root

RUN yum install -y \
    wget curl \
    git gettext tar net-tools && \
    yum clean all

RUN mkdir -p /zap/wrk
ADD zap /zap/

RUN mkdir -p /var/lib/jenkins/.vnc

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
ENV PATH $JAVA_HOME/bin:/zap:$PATH
ENV ZAP_PATH /zap/zap.sh
ENV HOME /var/lib/jenkins

# Default port for use with zapcli
ENV ZAP_PORT 8080

COPY policies /var/lib/jenkins/.ZAP/policies/
COPY .xinitrc /var/lib/jenkins/

WORKDIR /zap
# Download and expand the latest stable release 
RUN curl -s https://raw.githubusercontent.com/zaproxy/zap-admin/master/ZapVersions-dev.xml | grep "zaproxy/zaproxy/releases/download.*Linux" | sed 's@^[^>]*>\([^<]*\)<.*$@\1@g' | \
    wget -q --content-disposition -i - -O - | tar zx --strip-components=1 && \
    touch AcceptedLicense

RUN chown root:root /zap -R && \
    chown root:root -R /var/lib/jenkins && \
    chmod 777 /var/lib/jenkins -R && \
    chmod 777 /zap -R

WORKDIR /var/lib/jenkins

USER 1001
EXPOSE 8080

# Run the Jenkins JNLP client
ENTRYPOINT ["/usr/local/bin/run-jnlp-client"]
