#===============================================================================
ARG VARIANT="jammy"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

RUN  sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN  apt-get clean
RUN  apt-get update

ARG PG_HOME=/home/vscode/workspace
ARG PG_BUILD=/home/vscode/build
ARG PG_DATA=/home/vscode/data
ARG PG_USER=vscode


#-------------------------------------------------------------------------------

RUN echo "root:root" | chpasswd

#RUN yum upgrade
RUN apt-get install -y flex \
    bison \
    libreadline-dev  \
    libssl-dev  \
    libpam-dev   \
    libxml2 \
    libxml2-dev  \
    libxslt-dev  \
    libldap-dev  \
    libldap-dev  \
    libperl-dev  \
    python3-dev \
    zlib1g-dev  \
    gdb \
    libssh2-1-dev \
    make \
    gcc \
    g++

RUN apt clean all

RUN mkdir -p ${PG_BUILD} ${PG_HOME}   && \
    chown -R ${PG_USER}:${PG_USER} ${PG_BUILD} ${PG_HOME}

#-------------------------------------------------------------------------------
WORKDIR ${PG_HOME}

COPY --chown=${PG_USER}:${PG_USER} lib/ ${PG_HOME}
#-------------------------------------------------------------------------------
USER ${PG_USER}

WORKDIR ${PG_HOME}/postgres-xc

RUN ./configure --prefix ${PG_BUILD} && \
    make && \
    cd contrib/pgxc_monitor && \
    make

# WORKDIR ${PG_HOME}/lib/benchmarksql

# RUN ant
#-------------------------------------------------------------------------------
USER root

WORKDIR ${PG_HOME}/postgres-xc

RUN make install && \
    cd contrib/pgxc_monitor && \
    make install
#-------------------------------------------------------------------------------
USER ${PG_USER}

WORKDIR ${PG_HOME}

ENV PATH=${PG_BUILD}/bin:$PATH \
    PGDATA=${PG_DATA} \
    PG_USER_HEALTHCHECK=_healthcheck

COPY bin/* ${PG_BUILD}/bin/
# COPY ci/ ./ci/

# VOLUME ${PG_HOME}
#===============================================================================
