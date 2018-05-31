FROM store/oracle/serverjre:8
ENV MULE_VERSION=3.9.0 \
    # Name of file which the Mule ESB distribution will be downloaded to.
    MULE_ARCHIVE="mule-standalone.tar.gz" \
    # Parent directory in which the Mule installation directory will be located.
    INSTALLATION_PARENT=/opt \
    # Name of Mule installation directory.
    INSTALLATION_DIRECTORY_NAME=mule-standalone \
    # User and group that the Mule ESB instance will be run as, in order not to run as root.
    # Note that the name of this property must match the property name used in the Mule ESB startup script.
    RUN_AS_USER=mule \
    # Set this environment variable to true to set timezone on container start.
    SET_CONTAINER_TIMEZONE=true \
    # Default container timezone.
    CONTAINER_TIMEZONE=Europe/Moscow
ENV MULE_DOWNLOAD_URL=https://repository-master.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/${MULE_VERSION}/mule-standalone-${MULE_VERSION}.tar.gz \
    MULE_HOME="$INSTALLATION_PARENT/$INSTALLATION_DIRECTORY_NAME"
    # Add user (and group) which will run Mule ESB in the container.
ADD ${MULE_DOWNLOAD_URL} ${INSTALLATION_PARENT}
RUN yum update -y && \
    groupadd -f ${RUN_AS_USER} && \
    useradd --system --home /home/${RUN_AS_USER} -g ${RUN_AS_USER} ${RUN_AS_USER} && \
    # Updates for Debian.
    # Install NTP for time synchronization, wget to download stuff and
    # procps since Mule uses the ps command and it is not installed per default.
    yum install -y ntp wget procps && \
    # Clean up.
    yum clean all && \
    # Download and unpack Mule ESB.
    cd ${INSTALLATION_PARENT} && \
    tar xvzf mule-standalone-*.tar.gz && \
    rm mule-standalone-*.tar.gz && \
    mv mule-standalone-* ${INSTALLATION_DIRECTORY_NAME} && \
    chown -R ${RUN_AS_USER}:${RUN_AS_USER} ${MULE_HOME}
WORKDIR ${MULE_HOME}
USER ${RUN_AS_USER}
VOLUME ["${MULE_HOME}/logs", "${MULE_HOME}/conf", "${MULE_HOME}/apps", "${MULE_HOME}/domains"]
CMD ["/opt/mule-standalone/bin/mule"]