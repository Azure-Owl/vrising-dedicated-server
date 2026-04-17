FROM ubuntu:22.04

ENV UID 1000
ENV GID 1000

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        wine \
        winbind \
        xvfb \
        ca-certificates \
        lib32gcc-s1 \
        wget \
    && rm -rf /var/lib/apt/lists/*    

RUN groupadd -g $GID vrising \
    && useradd -u $UID vrising -g vrising

RUN mkdir -p /vrising \
    && mkdir -p /steamcmd \
    && mkdir -p /serverData \
    && mkdir -p /home/vrising \
    && mkdir -p /home/vrising/.wine

ADD install.sh /steamcmd/install.sh

RUN chown -R vrising:vrising /vrising \
    && chown -R vrising:vrising /steamcmd \
    && chown -R vrising:vrising /serverData \
    && chown -R vrising:vrising /home/vrising \
    && chown -R vrising:vrising /home/vrising/.wine \
    && chown -R vrising:vrising /tmp

RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

VOLUME ["/vrising"]
VOLUME ["/serverData"]

USER vrising:vrising

RUN cd /steamcmd \
    && wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    && tar -zxvf steamcmd_linux.tar.gz \
    && rm steamcmd_linux.tar.gz \
    && chmod u+x ./steamcmd.sh

RUN chmod u+x /steamcmd/install.sh

ENTRYPOINT ["steamcmd/install.sh"]
