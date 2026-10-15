FROM ubuntu:26.04

ARG UID=1000
ARG GID=1000

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates wget \
    && mkdir -pm755 /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/winehq-archive.asc https://dl.winehq.org/wine-builds/winehq.key \
    && printf 'Types: deb\nURIs: https://dl.winehq.org/wine-builds/ubuntu\nSuites: resolute\nComponents: main\nArchitectures: amd64\nSigned-By: /etc/apt/keyrings/winehq-archive.asc\n' \
        > /etc/apt/sources.list.d/winehq.sources \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        winehq-stable \
        winbind \
        lib32gcc-s1 \
        procps \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /opt/wine-stable/lib/wine/i386-windows \
    && find /opt/wine-stable -name '*.a' -delete

RUN userdel -r ubuntu 2>/dev/null || true

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

VOLUME ["/vrising"]
VOLUME ["/serverData"]

USER vrising:vrising

RUN cd /steamcmd \
    && wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    && tar -zxvf steamcmd_linux.tar.gz \
    && rm steamcmd_linux.tar.gz \
    && chmod u+x ./steamcmd.sh

RUN chmod u+x /steamcmd/install.sh

#Remove 32 bit dlls to save space
RUN wine reg add 'HKCU\Software\Wine\Drivers' /v Graphics /d null /f \
    && wineserver -w \
    && find /home/vrising/.wine/drive_c/windows/system32 -type f | while read -r f; do \
        o=/opt/wine-stable/lib/wine/x86_64-windows/${f##*/}; \
        if cmp -s "$f" "$o"; then ln -sf "$o" "$f"; fi; \
    done

ENV WINEDLLOVERRIDES="winedbg.exe=d"

ENTRYPOINT ["/steamcmd/install.sh"]
