FROM alpine

RUN apk add --no-cache drill

WORKDIR /app

COPY test.sh .

CMD [ "./test.sh" ]