ARG UBUNTU_VERSION=focal-20210119
FROM ubuntu:${UBUNTU_VERSION}

ARG TREX_VERSION=v3.06

RUN apt-get update \
    && apt-get -y install --no-install-recommends \
    iproute2 \
    openssh-server \
    iputils-ping \
    libarchive13 \
    ethtool \
    net-tools \
    netbase \
    pciutils \
    python3 \
    python3-distutils \
    strace \
    supervisor \
    wget \
    && apt-get autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf    

RUN echo 'root:cisco123' | chpasswd
RUN mkdir /var/run/sshd
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config    
RUN sed -i 's/root:x:0:0:root:\/root:\/bin\/bash/root:x:0:0:root:\/v3.06:\/bin\/bash/' /etc/passwd
EXPOSE 22

ENV NOTVISIBLE="in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN wget --no-check-certificate https://trex-tgn.cisco.com/trex/release/${TREX_VERSION}.tar.gz && \
    tar -zxvf ${TREX_VERSION}.tar.gz -C / && \
    chown root:root /${TREX_VERSION}  && \
    rm ${TREX_VERSION}.tar.gz
    
COPY trex_cfg.yaml /etc/trex_cfg.yaml

WORKDIR /${TREX_VERSION}
# COPY trex.sh trex.sh

CMD ["/usr/bin/supervisord"]

#CMD ["./t-rex-64", "-i", "--cfg", "/etc/trex_cfg.yaml"]