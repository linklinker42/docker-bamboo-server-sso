#FROM registry.cloudbrocktec.com/redhat/ubi/ubi8
FROM localhost/redhat/ubi/ubi8:8.2
#FROM adoptopenjdk:8-jdk-hotspot-bionic
LABEL maintainer="Atlassian Bamboo Team" \
     description="Official Bamboo Server Docker Image"

ENV BAMBOO_USER bamboo
ENV BAMBOO_GROUP bamboo

ENV SSO_ENABLED false
ENV BROKER_CLIENT_URI tcp://localhost:54663

ENV BAMBOO_USER_HOME /home/${BAMBOO_USER}
ENV BAMBOO_HOME /var/atlassian/application-data/bamboo
ENV BAMBOO_INSTALL_DIR /opt/atlassian/bamboo

# Expose HTTP and AGENT JMS ports
ENV BAMBOO_JMS_CONNECTION_PORT=54663
EXPOSE 8085
EXPOSE $BAMBOO_JMS_CONNECTION_PORT

RUN set -x && \
     groupadd ${BAMBOO_GROUP} && \
     adduser ${BAMBOO_USER} --home ${BAMBOO_USER_HOME} -g ${BAMBOO_GROUP}
	 #usermod -g ${BAMBOO_GROUP} ${BAMBOO_USER}

RUN set -x && \
     yum update -y && \
	 yum install -y \
	 java-1.8.0-openjdk-devel.x86_64 \
     curl \
     git \
     bash \
     procps \
     openssl \
     openssh-clients \
     libtcnative-1 \
     maven \
     python3 python3-jinja2 \
     xmlstarlet \
     && \
     # create symlink to maven to automate capability detection
     ln -s /usr/share/maven /usr/share/maven3 && \
     # create symlink for java home backward compatibility
     mkdir -m 755 -p /usr/lib/jvm && \
     ln -s "${JAVA_HOME}" /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.262.b10-0.el8_2.x86_64/jre && \
     rm -rf /var/lib/apt/lists/*

#RUN set -x && \
#     apt-get update && \
#     apt-get install -y --no-install-recommends \
#     curl \
#     git \
#     bash \
#     procps \
#     openssl \
#     openssh-client \
#     libtcnative-1 \
#     maven \
#     python3 python3-jinja2 \
#     xmlstarlet \
#     && \
#     # create symlink to maven to automate capability detection
#     ln -s /usr/share/maven /usr/share/maven3 && \
#     # create symlink for java home backward compatibility
#     mkdir -m 755 -p /usr/lib/jvm && \
#     ln -s "${JAVA_HOME}" /usr/lib/jvm/java-8-openjdk-amd64 && \
#     rm -rf /var/lib/apt/lists/*

ARG BAMBOO_VERSION
ARG DOWNLOAD_URL=https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-${BAMBOO_VERSION}.tar.gz

RUN set -x && \
     mkdir -p ${BAMBOO_INSTALL_DIR}/lib/native && \
     mkdir -p ${BAMBOO_HOME} && \
     ln --symbolic "/usr/lib/x86_64-linux-gnu/libtcnative-1.so" "${BAMBOO_INSTALL_DIR}/lib/native/libtcnative-1.so" && \
     curl --silent -L ${DOWNLOAD_URL} | tar -xz --strip-components=1 -C "$BAMBOO_INSTALL_DIR" && \
     echo "bamboo.home=${BAMBOO_HOME}" > $BAMBOO_INSTALL_DIR/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties && \
     chown -R "${BAMBOO_USER}:${BAMBOO_GROUP}" "${BAMBOO_INSTALL_DIR}" && \
     chown -R "${BAMBOO_USER}:${BAMBOO_GROUP}" "${BAMBOO_HOME}"

VOLUME ["${BAMBOO_HOME}"]
WORKDIR $BAMBOO_HOME

USER ${BAMBOO_USER}
COPY  --chown=bamboo:bamboo entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entryScript.sh"]

COPY entryScript.sh /
COPY entrypoint.py /
COPY entrypoint_helpers.py /
COPY server.xml.j2 /opt/atlassian/etc/
COPY login.ftl.j2 /opt/atlassian/etc/login.ftl.j2
COPY bamboo-seraph-config.xml /opt/atlassian/sso/seraph-config.xml
COPY bamboo-crowd.properties /opt/atlassian/sso/crowd.properties
