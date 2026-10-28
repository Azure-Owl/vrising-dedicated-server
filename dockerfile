FROM ubuntu:26.04

ARG UID=1000
ARG GID=1000

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends ca-certificates wget locales \
    && locale-gen en_US.UTF-8 \
    && mkdir -p /tmp/dummy/DEBIAN \
    && printf 'Package: libasound2-plugins\nVersion: 99.0\nArchitecture: amd64\nMaintainer: none\nDescription: Empty placeholder, audio plugins are not needed\n' \
        > /tmp/dummy/DEBIAN/control \
    && dpkg-deb -b /tmp/dummy /tmp/libasound2-plugins.deb \
    && dpkg -i /tmp/libasound2-plugins.deb \
    && rm -rf /tmp/dummy /tmp/libasound2-plugins.deb /usr/bin/pebble \
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

RUN install -d -o vrising -g vrising \
        /vrising /steamcmd /serverData /home/vrising /home/vrising/.wine

COPY --chown=vrising:vrising --chmod=755 install.sh /steamcmd/install.sh

VOLUME ["/vrising"]
VOLUME ["/serverData"]

USER vrising:vrising

# Let steamcmd update itself at build time instead of on every container start.
# Its first run can fail right after self-updating, so try twice.
RUN cd /steamcmd \
    && wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    && tar -zxf steamcmd_linux.tar.gz \
    && rm steamcmd_linux.tar.gz \
    && chmod u+x ./steamcmd.sh \
    && { ./steamcmd.sh +quit || ./steamcmd.sh +quit; }

RUN wine reg add 'HKCU\Software\Wine\Drivers' /v Graphics /d null /f \
    && wineserver -w \
    && find /home/vrising/.wine/drive_c/windows/system32 -type f | while read -r f; do \
        o=/opt/wine-stable/lib/wine/x86_64-windows/${f##*/}; \
        if cmp -s "$f" "$o"; then ln -sf "$o" "$f"; fi; \
    done

ENV WINEDLLOVERRIDES="winedbg.exe=d"

# steamcmd asks for this locale and warns when it is missing
ENV LANG=en_US.UTF-8

# Silence wine's own debug output, set WINEDEBUG= (empty) to get it back
ENV WINEDEBUG=-all

ENTRYPOINT ["/steamcmd/install.sh"]
