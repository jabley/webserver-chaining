FROM haproxy:2.3

# We need to build luaossl as a .so that haproxy can load it. haproxy doesn't
# support lua's FFI, so we can't use FFI like openresty lua packages do.
# See https://github.com/openresty/lua-resty-string/blob/bf8cec1ca195f53bee1cd09c310a473927e62f79/lib/resty/random.lua for how that works.
RUN set -eux; \
    apt-get update >/dev/null 2>&1; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gcc \
        liblua5.3-dev \
        libssl-dev \
        make \
        unzip \
        wget \
        >/dev/null 2>&1 \
    ; \
    cd /usr/src ; \
    wget -qO luaossl.zip https://github.com/wahern/luaossl/archive/rel-20200709.zip ; \
    unzip -qo luaossl.zip ; \
    cd luaossl-*/ ; \
    make install5.3 >/dev/null ; \
    rm -rf /var/lib/apt/lists/* ;

# After doing all that, we can do `local rand = require "openssl.rand"` in a Lua script in haproxy.
