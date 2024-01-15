#!/bin/sh

/powertag/powertagd -d /dev/ttyACM0 | /powertag/powertag2mqtt -topic 'powertag/' -broker "tcp://192.168.8.102:1883"
