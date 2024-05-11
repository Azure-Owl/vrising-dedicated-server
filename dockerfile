FROM ubuntu:22.04

ENV UID 1000
ENV GID 1000

# install dependencies
RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get autoremove -y
RUN apt install software-properties-common lib32gcc-s1 libvorbisfile3 wget libstdc++6 -y

RUN groupadd -g $GID vrising \
    && useradd -u $UID vrising -g vrising

RUN mkdir -p /vrising \
    && mkdir -p /steamcmd

ADD install.sh /steamcmd/install.sh

RUN chown -R vrising:vrising /vrising \
    && chown -R vrising:vrising /steamcmd

VOLUME ["/starbound"]

USER vrising:vrising

# download and install steamcmd
RUN cd /steamcmd \
    && wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    && tar -zxvf steamcmd_linux.tar.gz \
    && rm steamcmd_linux.tar.gz \
    && chmod u+x ./steamcmd.sh

RUN chmod u+x /steamcmd/install.sh

RUN touch /steamcmd/installmods.txt

ENTRYPOINT ["steamcmd/install.sh"]
