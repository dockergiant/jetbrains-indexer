# Comment out the CMD line and uncomment the following for testing
# ENTRYPOINT ["tail", "-f", "/dev/null"]
FROM ubuntu:22.04

MAINTAINER Rick "rick@dockergiant.com"

ENV DEBIAN_FRONTEND noninteractive

ARG TARGETARCH="arm64"

#### ---------------------
#### ---- USER, GROUP ----
#### ---------------------
ENV USER_ID=${USER_ID:-1000}
ENV GROUP_ID=${GROUP_ID:-1000}

ENV JAVA_VERSION=19

ENV LANG C.UTF-8
ARG LIB_BASIC_LIST="curl wget unzip ca-certificates sh"
RUN set -eux; \
    apt-get update -y && \
    apt-get install -y ${LIB_BASIC_LIST}

########################################
#### update ubuntu and Install Python 3
########################################
ARG LIB_DEV_LIST="apt-utils automake pkg-config libpcre3-dev zlib1g-dev liblzma-dev"
ARG LIB_BASIC_LIST="curl iputils-ping nmap net-tools build-essential software-properties-common apt-transport-https"
ARG LIB_COMMON_LIST="bzip2 libbz2-dev git wget unzip vim python3-pip python3-setuptools python3-dev python3-venv python3-numpy python3-scipy python3-pandas python3-matplotlib"
ARG LIB_TOOL_LIST="graphviz libsqlite3-dev sqlite3 git xz-utils"

RUN apt-get update -y && \
    apt-get install -yq ${LIB_DEV_LIST} && \
    apt-get install -yq ${LIB_BASIC_LIST} && \
    apt-get install -yq ${LIB_COMMON_LIST} && \
    apt-get install -yq ${LIB_TOOL_LIST} && \
    apt-get install -yq sudo && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

########################################
#### ------- OpenJDK Installation ------
########################################
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
# A few reasons for installing distribution-provided OpenJDK:
#
#  1. Oracle.  Licensing prevents us from redistributing the official JDK.
#
#  2. Compiling OpenJDK also requires the JDK to be installed, and it gets
#     really hairy.
#
#     For some sample build times, see Debian's buildd logs:
#       https://buildd.debian.org/status/logs.php?pkg=openjdk-8

RUN apt-get update && apt-get install -y --no-install-recommends \
		bzip2 \
		unzip \
		xz-utils \
	&& rm -rf /var/lib/apt/lists/*

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ENV JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-${TARGETARCH}
ENV PATH=$JAVA_HOME/bin:$PATH


# ------------------
# OpenJDK Java:
# ------------------
ARG OPENJDK_PACKAGE=${OPENJDK_PACKAGE:-openjdk-${JAVA_VERSION}-jdk}
ARG OPENJDK_INSTALL_LIST="${OPENJDK_PACKAGE}"

RUN apt-get update -y && \
    apt-get install -y ${OPENJDK_INSTALL_LIST} && \
    ls -al ${JAVA_HOME} && \
    export PATH=$PATH ; echo "PATH=${PATH}" ; export JAVA_HOME=${JAVA_HOME} ; echo "java=`which java`" && \
    rm -rf /var/lib/apt/lists/*

## ------------------------------------------------------------------------------------------------
## update-alternatives so that future installs of other OpenJDK versions don't change /usr/bin/java
## ... and verify that it actually worked for one of the alternatives we care about
## ------------------------------------------------------------------------------------------------
#RUN update-alternatives --get-selections | awk -v home="$(readlink -f "$JAVA_HOME")" 'index($3, home) == 1 { $2 = "manual"; print | "update-alternatives --set-selections" }'; \
#	update-alternatives --query java | grep -q 'Status: manual'

###################################
#### ---- Install Maven 3 ---- ####
###################################
ENV MAVEN_VERSION=${MAVEN_VERSION:-3.9.2}
ENV MAVEN_HOME=/usr/apache-maven-${MAVEN_VERSION}
ENV MAVEN_PACKAGE=apache-maven-${MAVEN_VERSION}-bin.tar.gz
ENV PATH=${PATH}:${MAVEN_HOME}/bin
## -- Auto tracking (by parsing product release page) the latest release -- ##
# https://dlcdn.apache.org/maven/maven-3/3.9.2/binaries/apache-maven-3.9.2-bin.tar.gz
RUN export MAVEN_PACKAGE_URL=$(curl -s https://maven.apache.org/download.cgi | grep -e "apache-maven.*bin.tar.gz" | head -1|cut -d'"' -f2) && \
    export MAVEN_PACKAGE=$(basename $MAVEN_PACKAGE_URL) && \
    export MAVEN_VERSION=$(echo ${MAVEN_PACKAGE}|cut -d'-' -f3) && \
    export MAVEN_HOME=/usr/apache-maven-${MAVEN_VERSION} && \
    export PATH=${PATH}:${MAVEN_HOME}/bin && \
    curl -k -sL ${MAVEN_PACKAGE_URL} | gunzip | tar x -C /usr/ && \
    ln -s ${MAVEN_HOME}/bin/mvn /usr/bin/mvn && \ \
    rm -f ${MAVEN_PACKAGE}

RUN python3 -m pip install --upgrade pip

## -- added Local PIP installation bin to PATH
ENV PATH=${PATH}:${HOME}/.local/bin

## VERSIONS ##
ENV PATH=${PATH}:${JAVA_HOME}/bin

RUN mvn --version && \
    python3 -V && \
    pip3 --version

###################################
#### ---- Install Gradle ---- #####
###################################
# Ref: https://gradle.org/releases/

ENV GRADLE_INSTALL_BASE=${GRADLE_INSTALL_BASE:-/opt/gradle}
ENV GRADLE_VERSION=${GRADLE_VERSION:-8.1.1}
ENV GRADLE_PACKAGE=gradle-${GRADLE_VERSION}-bin.zip
ENV GRADLE_PACKAGE_URL=https://services.gradle.org/distributions/${GRADLE_PACKAGE}
ENV GRADLE_HOME=${GRADLE_INSTALL_BASE}/gradle-${GRADLE_VERSION}
ENV PATH=${PATH}:${GRADLE_HOME}/bin
# export GRADLE_PACKAGE_URL=$(curl -s https://gradle.org/releases/ | grep "Download: " | cut -d'"' -f4 | sort -u | tail -1) && \
## -- Auto tracking (by parsing product release page) the latest release -- ##
RUN mkdir -p ${GRADLE_INSTALL_BASE} && \
    cd ${GRADLE_INSTALL_BASE} && \
    export GRADLE_PACKAGE_URL=$(curl -k -s https://gradle.org/releases/ | grep "Download: " | head -1 | cut -d'"' -f4) && \
    export GRADLE_PACKAGE=$(basename ${GRADLE_PACKAGE_URL}) && \
    export GRADLE_VERSION=$(echo $GRADLE_PACKAGE|cut -d'-' -f2) && \
    export GRADLE_HOME=${GRADLE_INSTALL_BASE}/gradle-${GRADLE_VERSION} && \
    export PATH=${PATH}:${GRADLE_HOME}/bin && \
    wget -q --no-check-certificate -c ${GRADLE_PACKAGE_URL} && \
    unzip -d ${GRADLE_INSTALL_BASE} ${GRADLE_PACKAGE} && \
    ls -al ${GRADLE_HOME} && \
    ln -s ${GRADLE_HOME}/bin/gradle /usr/bin/gradle && \
    ${GRADLE_HOME}/bin/gradle -v && \
    rm -f ${GRADLE_PACKAGE}

#########################################
#### ---- Node from NODESOURCES ---- ####
#########################################
# Ref: https://github.com/nodesource/distributions
#ARG NODE_VERSION=${NODE_VERSION:-current}
# Ubuntu 18.04 missing GLC lib 2.28 needed by latest Node v18
# Hence stick to v17
ARG NODE_VERSION=${NODE_VERSION:-19}
ENV NODE_VERSION=${NODE_VERSION}
RUN apt-get update -y && \
    curl -sL -k https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

########################
#### ---- Yarn ---- ####
########################
# Ref: https://classic.yarnpkg.com/en/docs/install/#debian-stable
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update -y && \
    apt-get install -y yarn

###################################
#### ---- Update: all     ---- ####
###################################
RUN apt-get update -y && apt-get upgrade -y

# Shared indexing works best
# when you use the IDE
# corresponding to the language
# your project is in
ARG IDE=PhpStorm
ARG IDE_SHORT=phpstorm
ARG IDE_CODE=webide
ARG IDE_VERSION=2023.1.2

# persist build args for runtime
# see https://www.saltycrane.com/blog/2021/04/buildtime-vs-runtime-environment-variables-nextjs-docker/#setting-dynamic-buildtime-environment-variables-that-are-available-at-runtime-also
ENV IDE=$IDE
ENV IDE_SHORT=$IDE_SHORT
ENV IDE_CODE=$IDE_CODE
ENV IDE_VERSION=$IDE_VERSION

ARG IDE_TAR=${IDE}-${IDE_VERSION}.tar.gz
ARG CDN_LAYOUT_TOOL_VERSION=0.8.68

# Runtime variables
ENV INDEXES_CDN_URL=http://localhost:3000/project
ENV COMMIT_ID=''
ENV PROJECT_ID=''
ENV IDEA_PROJECT_DIR="/var/project"
ENV SHARED_INDEX_BASE="/shared-index"

USER root
WORKDIR /opt

# Set up folders
RUN mkdir -p /etc/idea && \
    mkdir -p /etc/idea/config && \
    mkdir -p /etc/idea/log && \
    mkdir -p /etc/idea/3plugins && \
    mkdir -p /etc/idea/system && \
    mkdir ${SHARED_INDEX_BASE} && \
    mkdir ${SHARED_INDEX_BASE}/output && \
    mkdir ${SHARED_INDEX_BASE}/temp

# Install IntelliJ IDEA Ultimate
# arm64 package url : https://download.jetbrains.com/webide/PhpStorm-2023.1.2-aarch64.tar.gz
RUN if [ "${TARGETARCH}" = "arm64" ]; then IDE_TAR="${IDE}-${IDE_VERSION}-aarch64.tar.gz"; fi && \
    wget -nv https://download-cf.jetbrains.com/${IDE_CODE}/${IDE_TAR} && \
    tar xzf ${IDE_TAR} && \
    tar tzf ${IDE_TAR} | head -1 | sed -e 's/\/.*//' | xargs -I{} ln -s {} idea && \
    rm ${IDE_TAR} && \
    echo idea.config.path=/etc/idea/config >> /opt/idea/bin/idea.properties && \
    echo idea.log.path=/etc/idea/log >> /opt/idea/bin/idea.properties && \
    echo idea.plugins.path=/etc/idea/plugins >> /opt/idea/bin/idea.properties && \
    echo idea.system.path=/etc/idea/system >> /opt/idea/bin/idea.properties && \
    chmod -R 777 /opt/idea && \
    chmod -R 777 ${SHARED_INDEX_BASE} && \
    chmod -R 777 /etc/idea

# Install cdn-layout-tool
RUN wget https://packages.jetbrains.team/maven/p/ij/intellij-shared-indexes-public/com/jetbrains/intellij/indexing/shared/cdn-layout-tool/${CDN_LAYOUT_TOOL_VERSION}/cdn-layout-tool-${CDN_LAYOUT_TOOL_VERSION}.zip -O cdn-layout-tool.zip && \
    unzip cdn-layout-tool.zip && \
    rm cdn-layout-tool.zip && \
    mv cdn-layout-tool-${CDN_LAYOUT_TOOL_VERSION} cdn-layout-tool


COPY entrypoint.sh entrypoint.sh
CMD ./entrypoint.sh

# Comment out the CMD line and uncomment the following for testing
# ENTRYPOINT ["tail", "-f", "/dev/null"]
