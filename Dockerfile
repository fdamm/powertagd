FROM golang:1.18-alpine as build

## Build powertag2mqtt
#WORKDIR /powertag2mqtt
#COPY powertag2mqtt/go.mod ./
#COPY powertag2mqtt/*.go ./
#RUN go mod tidy
#RUN go mod download && go mod verify
#RUN CGO_ENABLED=0 GOOS=linux go build -o /powertag2mqtt/powertag2mqtt

# Build powertagd
RUN apk update && apk upgrade
RUN apk add build-base
COPY src/ /powertagd/src
#RUN apk add git
#RUN git clone https://github.com/jlama/powertagd.git
WORKDIR /powertagd/src
RUN make clean && make

#FROM alpine
#
#RUN mkdir /powertag
#WORKDIR /powertag
#COPY --from=build /powertag2mqtt/powertag2mqtt .
#COPY --from=build /powertagd/src/powertagd /powertagd/src/powertagctl ./
#
#COPY run.sh ./
#RUN chmod +x ./run.sh
#
#ENTRYPOINT ["/powertag/run.sh"]
##ENTRYPOINT ["/bin/sh"]
##ENTRYPOINT ["/bin/sleep", "6000"]

# For more information, please refer to https://aka.ms/vscode-docker-python
FROM python:3.12-alpine

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

RUN mkdir /app
WORKDIR /app

# Install pip requirements
COPY powertag2mqtt/requirements.txt .
RUN python -m pip install --no-cache-dir --upgrade -r requirements.txt

COPY powertag2mqtt/*.py /app
COPY --from=build /powertagd/src/powertagd /powertagd/src/powertagctl ./

COPY run.sh ./
RUN chmod +x ./run.sh


RUN mkdir /var/lib/data
ENV HOME_DIR /var/lib/appdata


## Creates a non-root user with an explicit UID and adds permission to access the /app folder
## For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
#RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
#USER appuser

ENTRYPOINT ["/app/run.sh"]
#ENTRYPOINT ["/bin/sleep", "6000"]
