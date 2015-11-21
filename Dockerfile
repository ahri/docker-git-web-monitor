FROM alpine:3.2

RUN apk add --update git=2.4.1-r0 perl=5.20.2-r0 && \
    rm -rf /var/cache/apk/*

EXPOSE 8080

USER nobody
ENTRYPOINT ["/monitor.sh"]

ADD monitor.sh /
