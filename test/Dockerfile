FROM alpine

RUN apk add --no-cache bind-tools

WORKDIR /app

COPY start.sh .

CMD [ "sh", "run.sh" ]