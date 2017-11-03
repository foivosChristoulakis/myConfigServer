FROM frolvlad/alpine-oraclejdk8:slim

ARG devEnvDockerArg
ENV devEnvDockerArg=${devEnvDockerArg}



# maven build java project and move executable jar
# ------------------------
RUN mkdir /opt && \
    wget --no-verbose -O /tmp/apache-maven-3.3.9.tar.gz \
    http://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz && \
    tar xzf /tmp/apache-maven-3.3.9.tar.gz -C /opt/ && \
    ln -s /opt/apache-maven-3.3.9 /opt/maven && \
    ln -s /opt/maven/bin/mvn /usr/local/bin && \
    rm -f /tmp/apache-maven-3.3.9.tar.gz
ENV MAVEN_HOME /opt/maven

#ADD jce/jce_policy-8.zip /usr/lib/jvm/java-8-oracle/jre/lib/security
#COPY jce/local_policy.jar /usr/lib/jvm/java-8-oracle/jre/lib/security
#COPY jce/US_export_policy.jar /usr/lib/jvm/java-8-oracle/jre/lib/security

ENV SERVER_HOME /var/config-server
ENV CONFIG_HOME /opt/configuration-properties

RUN mkdir -p $SERVER_HOME/src && \
    mkdir -p /var/log/config-server
ADD server $SERVER_HOME/src

WORKDIR ${SERVER_HOME}/src
RUN mvn clean package && \
    mv target/epos2-config-server-develop-SNAPSHOT.jar $SERVER_HOME && \
    mvn clean
#---------------------------


RUN echo ${devEnvDockerArg}

# add config data (only defaults and environment specific settings)
ADD config $CONFIG_HOME


WORKDIR ${SERVER_HOME}
ENTRYPOINT exec java -jar epos2-config-server-develop-SNAPSHOT.jar --devEnv=${devEnvDockerArg}
EXPOSE 8080
EXPOSE 443

