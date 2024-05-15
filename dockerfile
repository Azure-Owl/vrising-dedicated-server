FROM ubuntu:22.04

ENV UID 1000
ENV GID 1000

# install dependencies
RUN apt update && apt upgrade -y
RUN apt install wine -y
RUN apt install xvfb xserver-xorg -y
RUN apt install apt-utils software-properties-common lib32gcc-s1 wget -y
RUN dpkg --add-architecture i386 && apt-get update && apt-get install wine32 -y
RUN apt install winbind winetricks -y

RUN groupadd -g $GID vrising \
    && useradd -u $UID vrising -g vrising

RUN mkdir -p /vrising \
    && mkdir -p /steamcmd \
    && mkdir -p /serverData \
    && mkdir -p /home/vrising/.wine

ADD install.sh /steamcmd/install.sh

RUN chown -R vrising:vrising /vrising \
    && chown -R vrising:vrising /steamcmd \
    && chown -R vrising:vrising /serverData \
    && chown -R vrising:vrising /home/vrising/.wine

VOLUME ["/vrising"]
VOLUME ["/serverData"]

USER vrising:vrising

# download and install steamcmd
RUN cd /steamcmd \
    && wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    && tar -zxvf steamcmd_linux.tar.gz \
    && rm steamcmd_linux.tar.gz \
    && chmod u+x ./steamcmd.sh

RUN chmod u+x /steamcmd/install.sh

ENTRYPOINT ["steamcmd/install.sh"]
