# This dockerfile builds the zap stable release
FROM fedora:latest
MAINTAINER Deven Phillips <deven.phillips@redhat.com>

RUN dnf install -y redhat-rpm-config make automake autoconf gcc gcc-c++ libstdc++ libstdc++-devel java-1.8.0-openjdk ruby wget curl xmlstarlet unzip git x11vnc xorg-x11-server-Xvfb openbox xterm net-tools ruby-devel python-pip firefox 
#RUN apt-get update && apt-get install -q -y --fix-missing \
#	make \
#	automake \
#	autoconf \
#	gcc g++ \
#	openjdk-8-jdk \
#	ruby \
#	wget \
#	curl \
#	xmlstarlet \
#	unzip \
#	git \
#	x11vnc \
#	xvfb \
#	openbox \
#	xterm \
#	net-tools \
#	ruby-dev \
#	python-pip \
#	firefox \
#	xvfb \
#	x11vnc && \
#	apt-get clean && \
#	rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip
RUN gem install zapr
RUN pip install zapcli
# Install latest dev version of the python API
RUN pip install python-owasp-zap-v2.4

RUN mkdir /zap 
WORKDIR /zap
RUN chown root:root /zap -R

#Change to the zap user so things get done as the right person (apart from copy)

RUN mkdir /root/.vnc



# Download and expand the latest stable release 
RUN curl -s https://raw.githubusercontent.com/zaproxy/zap-admin/master/ZapVersions-dev.xml | xmlstarlet sel -t -v //url |grep -i Linux | wget --content-disposition -i - -O - | tar zxv && \
	cp -R ZAP*/* . &&  \
	rm -R ZAP* && \
	curl -s -L https://bitbucket.org/meszarv/webswing/downloads/webswing-2.3-distribution.zip > webswing.zip && \
	unzip *.zip && \
	rm *.zip && \
	touch AcceptedLicense


ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
ENV PATH $JAVA_HOME/bin:/zap/:$PATH
ENV ZAP_PATH /zap/zap.sh

# Default port for use with zapcli
ENV ZAP_PORT 8080
ENV HOME /root/


COPY zap-x.sh /zap/ 
COPY zap-* /zap/ 
COPY zap_* /zap/ 
COPY webswing.config /zap/webswing-2.3/ 
COPY policies /root/.ZAP/policies/
COPY .xinitrc /root/

RUN chown root:root /zap/zap-x.sh && \
	chown root:root /zap/zap-baseline.py && \
	chown root:root /zap/zap-webswing.sh && \
	chown root:root /zap/webswing-2.3/webswing.config && \
	chown root:root -R /root/.ZAP/ && \
	chown root:root /root/.xinitrc && \
	chmod a+x /root/.xinitrc && \
	chown root:root /root -R
#Change back to zap at the end
HEALTHCHECK --retries=5 --interval=5s CMD zap-cli status
