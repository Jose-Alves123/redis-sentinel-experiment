FROM docker:27-dind

RUN apk add --no-cache bash

WORKDIR /app

COPY compose.yml .
COPY slave-one.conf .
COPY slave-two.conf .
COPY sentinel-one.conf .
COPY sentinel-two.conf .

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]