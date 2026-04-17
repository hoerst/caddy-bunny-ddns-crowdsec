FROM caddy:2-builder AS builder
RUN xcaddy build \
    --with github.com/caddy-dns/bunny \
    --with github.com/mholt/caddy-dynamicdns \
    --with github.com/hslatman/caddy-crowdsec-bouncer/http \
    --with github.com/alectrocute/caddy-bunnynet-ip
FROM caddy:2
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
