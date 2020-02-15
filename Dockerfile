FROM osrm/osrm-backend

# Dockerfile Maintainer                                                         
MAINTAINER Tomas Fiser "tomas.fiser7@gmail.com"

# Some bug on Debian - https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=863199
RUN mkdir -p /usr/share/man/man1

# This is in accordance to : https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-get-on-ubuntu-16-04
RUN apt-get update && \
	apt-get install -y openjdk-8-jdk && \
	apt-get install -y ant && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer;
	
# Fix certificate issues, found as of 
# https://bugs.launchpad.net/ubuntu/+source/ca-certificates-java/+bug/983302
RUN apt-get update && \
	apt-get install -y ca-certificates-java && \
	apt-get clean && \
	update-ca-certificates -f && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer;

# Setup JAVA_HOME, this is useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME


COPY data /opt

# Go to workdir with OSRM binary files
WORKDIR /usr/local/bin

# Prepare data for OSRM Driving
RUN osrm-extract /opt/prague/prague.osm.pbf -p /opt/car.lua && \
    mkdir /opt/prague/driving && \
    mv /opt/prague/prague.osrm* /opt/prague/driving && \
    osrm-contract /opt/prague/driving/prague.osrm;

# Prepare data for OSRM Cycling
RUN osrm-extract /opt/prague/prague.osm.pbf -p /opt/bicycle.lua && \
    mkdir /opt/prague/cycling && \
    mv /opt/prague/prague.osrm* /opt/prague/cycling && \
    osrm-contract /opt/prague/cycling/prague.osrm;

# Prepare data for OSRM Walking
RUN osrm-extract /opt/prague/prague.osm.pbf -p /opt/foot.lua && \
    mkdir /opt/prague/walking && \
    mv /opt/prague/prague.osrm* /opt/prague/walking && \
    osrm-contract /opt/prague/walking/prague.osrm;

RUN mkdir /data