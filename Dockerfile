FROM alpine:3.12.7 AS stage
LABEL maintainer="Nicolas Favre-Felix <n.favrefelix@gmail.com>"

RUN apk update && apk add wget make gcc libevent-dev msgpack-c-dev musl-dev bsd-compat-headers jq
COPY . webdis
RUN cd webdis && make && make install && cd ..
RUN sed -i -e 's/"daemonize":.*true,/"daemonize": false,/g' /etc/webdis.prod.json

# main image
FROM alpine:3.12.7
RUN apk update && apk add libevent msgpack-c redis       # Required dependencies
RUN apk add libcrypto1.1                                 # Security updates
COPY --from=stage /usr/local/bin/webdis /usr/local/bin/
COPY --from=stage /etc/webdis.prod.json /etc/webdis.prod.json
RUN echo "daemonize yes" >> /etc/redis.conf
CMD /usr/bin/redis-server /etc/redis.conf && /usr/local/bin/webdis /etc/webdis.prod.json

EXPOSE 7379
