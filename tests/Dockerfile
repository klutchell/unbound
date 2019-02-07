FROM alpine

RUN apk add --no-cache bind-tools

WORKDIR /app

COPY test.sh .

CMD [ "/bin/sh", "test.sh" ]