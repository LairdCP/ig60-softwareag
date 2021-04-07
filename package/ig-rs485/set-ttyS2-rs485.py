#!/usr/bin/python3
import os

setGPIO = 'echo 1 > /sys/devices/platform/gpio/ser_nrs232/value'
setSTTY = 'stty -F /dev/ttyS2 9600 cs8 -cstopb -parenb rs485'
os.system(setGPIO)
print('GPIO ser_nrs232 set to 1')
os.system(setSTTY)
print('/dev/ttyS2 set to 9600 baud,8 N 1, RS-485 enabled')
