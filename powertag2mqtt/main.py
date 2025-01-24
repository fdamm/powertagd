import os
import sys
import json
import paho.mqtt.client as mqtt
import logging
from logging.handlers import TimedRotatingFileHandler

import Config

logger = logging.getLogger("PowerTagToMQTT")


def mqtt_service():
   client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
   client.on_connect = on_connect
   
   client.connect(Config.get_setting('mqtt.server'), 1883, 60)
   client.loop_start()
   return client


def on_connect(client, userdata, flags, reason_code, properties):
    logger.info(f"Connected with result code {reason_code}")


def parse_message(line):
    logger.debug(f"Message received:\n{line}")

    if not line.startswith("powertag,"):
        return None
    # Parse a line with the following format:
    # powertag,id=0xe2045fca total_power_active=-2585,power_p1_active=-813,power_p2_active=-1012,power_p3_active=-758,total_power_apparent=3277,freq=50.10 1707720992
    try:
        result =  {}
        splitted = line[9:-1].split(" ")
        result["id"] = splitted[0].split("=")[1]
        result["timestamp"] = splitted[2]
        for measure in splitted[1].split(","):
           keyvalue = measure.split("=")
           result[keyvalue[0]] = keyvalue[1]
        return result
    except Exception as e:
        logger.debug(f"Failed to parse received message:\n{line}\nException type: {type(e)}\nException args: {e.args}")


def main(args):
    homedir = args[1] if len(args) > 1 else os.environ.get('HOME_DIR', '.')
    Config.set_setting("homedir", homedir)
    Config.load_config()
    os.makedirs(f"{Config.get_setting('homedir')}/log", exist_ok=True)
    topic = Config.get_setting("mqtt.topic")

    logging_level = logging.DEBUG
    logger.setLevel(logging_level)
    formatter = logging.Formatter('%(asctime)s %(name)s %(levelname)s %(message)s')
    handler = \
        TimedRotatingFileHandler(
            f"{Config.get_setting('homedir')}/log/PowerTagToMQTT.log",
            when="midnight",
            interval=1,
            backupCount=5)
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    
    client = mqtt_service()
    
    for line in sys.stdin:
        message = parse_message(line)
        if message is not None:
            logger.debug(f"Publishing message: {json.dumps(message)}")
            client.publish(f"{topic}/{message["id"]}", json.dumps(message).encode())
        else:
            logger.info(f"Unexpected input: {line}")


#l = "powertag,id=0xe2045fca total_power_active=-2585,power_p1_active=-813,power_p2_active=-1012,power_p3_active=-758,total_power_apparent=3277,freq=50.10 1707720992"
#print(parse_message(l))

main(sys.argv)
