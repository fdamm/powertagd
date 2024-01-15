FROM golang:1.18-alpine as build

# Build powertag2mqtt
WORKDIR /powertag2mqtt
COPY powertag2mqtt/go.mod ./
COPY powertag2mqtt/*.go ./
RUN go mod tidy
RUN go mod download && go mod verify
RUN CGO_ENABLED=0 GOOS=linux go build -o /powertag2mqtt/powertag2mqtt

# Build powertagd
RUN apk update && apk upgrade
RUN apk add build-base
COPY src/ /powertagd/src
#RUN apk add git
#RUN git clone https://github.com/jlama/powertagd.git
WORKDIR /powertagd/src
RUN make clean && make

FROM alpine

RUN mkdir /powertag
WORKDIR /powertag
COPY --from=build /powertag2mqtt/powertag2mqtt .
COPY --from=build /powertagd/src/powertagd /powertagd/src/powertagctl ./

COPY run.sh ./
RUN chmod +x ./run.sh

ENTRYPOINT ["/powertag/run.sh"]
#ENTRYPOINT ["/bin/sh"]
#ENTRYPOINT ["/bin/sleep", "6000"]

