FROM woahbase/alpine-glibc:2.39 as build

# Build powertagd
RUN apk update && apk upgrade
RUN apk add build-base
COPY src/ /powertagd/src
#RUN apk add git
#RUN git clone https://github.com/jlama/powertagd.git
WORKDIR /powertagd/src
RUN make clean && make

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
