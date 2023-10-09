FROM ubuntu:23.10
MAINTAINER CherryChain <team@cherrychain.it>

ENV VERSION_TOOLS "10406996"

ENV ANDROID_SDK_ROOT "/sdk"
ENV PATH "$PATH:${ANDROID_CMDLINE_TOOLS_BIN}/:${ANDROID_HOME}/emulator/:${ANDROID_HOME}/platform-tools/:${ANDROID_HOME}/build-tools/33.0.1/"

# Keep alias for compatibility
ENV ANDROID_HOME "${ANDROID_SDK_ROOT}"
ENV PATH "$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"

ARG JDK_VERSION=21
ARG ANDROID_CMDLINE_TOOLS_BIN="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin"
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update \
 && apt-get install -qqy --no-install-recommends \
      bzip2 \
      curl \
      git-core \
      html2text \
      openjdk-${JDK_VERSION}-jdk \
      libc6-i386 \
      lib32stdc++6 \
      libtool \
      lib32ncurses6 \
      lib32z1 \
      unzip \
      locales \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN curl -s https://dl.google.com/android/repository/commandlinetools-linux-${VERSION_TOOLS}_latest.zip > /cmdline-tools.zip \
 && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
 && unzip /cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
 && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
 && rm -v /cmdline-tools.zip

RUN yes | ${ANDROID_CMDLINE_TOOLS_BIN}/sdkmanager --licenses

RUN mkdir -p /root/.android \
 && touch /root/.android/repositories.cfg \
 && sdkmanager --verbose --update

ADD packages.txt /sdk
RUN sdkmanager --verbose --package_file=/sdk/packages.txt
