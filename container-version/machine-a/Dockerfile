FROM docker:27-dind

RUN apk add --no-cache bash

WORKDIR /app

COPY compose.yml .
COPY master.conf .
COPY slave.conf .
COPY sentinel.conf .

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]