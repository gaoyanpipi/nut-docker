FROM ubuntu:16.04

MAINTAINER Max I. Shaposhnikoff <max@shaposhnikoff.info>

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ARG APT_FLAGS_COMMON="-qq -y"
ARG APT_FLAGS_PERSISTANT="${APT_FLAGS_COMMON} --no-install-recommends"
ARG APT_FLAGS_DEV="${APT_FLAGS_COMMON} --no-install-recommends"
ENV DEBIAN_FRONTEND=noninteractive TERM=xterm
ENV INSTALLDIR=/

RUN  apt-get ${APT_FLAGS_COMMON} update && \
     apt-get ${APT_FLAGS_PERSISTANT} install \
            git \
            mc \
            build-essential \
            python \
            libusb-dev \
            openssh-server \
            dh-autoreconf \
            libcppunit-dev \
            ca-certificates pkg-config bash-completion

RUN git clone https://github.com/networkupstools/nut.git /tmp/nut
WORKDIR /tmp/nut
RUN cd /tmp/nut && ./autogen.sh && ./configure --prefix=${INSTALLDIR} && make && make install
RUN cp /tmp/nut/scripts/systemd/*.service /lib/systemd/system/
ADD 52-nut-usbips.rules /lib/udev/rules.d/

RUN mkdir -p /var/state/ups

RUN systemctl enable nut-driver.service
RUN systemctl enable nut-monitor.service
RUN systemctl enable nut-server.service

RUN cp ${INSTALLDIR}/etc/nut.conf.sample ${INSTALLDIR}/etc/nut.conf
RUN cp ${INSTALLDIR}/etc/ups.conf.sample ${INSTALLDIR}/etc/ups.conf
RUN cp ${INSTALLDIR}/etc/upsd.conf.sample ${INSTALLDIR}/etc/upsd.conf
RUN cp ${INSTALLDIR}/etc/upsd.users.sample ${INSTALLDIR}/etc/upsd.users.conf
RUN cp ${INSTALLDIR}/etc/upsmon.conf.sample ${INSTALLDIR}/etc/upsmon.conf
RUN cp ${INSTALLDIR}/etc/upssched.conf.sample ${INSTALLDIR}/etc/upssched.conf





