# Created by: Maciej Burakowski
# Title: Alphabot2 kinect gesture control
# Date: 7/06/2024
# Description:
#   This app allows to control Alphabot2 Pi using gestures, captured by Kinect v2 and Processing software

# Libraries
import asyncio
import websockets
import RPi.GPIO as GPIO
from time import sleep
import atexit

# GPIO pin setup for Alphabot2 motors
Motor1A = 13    # Left motor forward
Motor1B = 12    # Left motor backward
ENA = 6        # PWM control for left motor

Motor2A = 21    # Right motor forward
Motor2B = 20     # Right motor backward
ENB = 26        # PWM control for right motor

# Global speed variable
speed = 30  # Adjust this value to set the speed (0-100)
turning_speed = 7 # Adjust this value to set the turning speed (0-100)
# Setup GPIO
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(Motor1A, GPIO.OUT)
GPIO.setup(Motor1B, GPIO.OUT)
GPIO.setup(ENA, GPIO.OUT)
GPIO.setup(Motor2A, GPIO.OUT)
GPIO.setup(Motor2B, GPIO.OUT)
GPIO.setup(ENB, GPIO.OUT)

# Initialize PWM on ENA and ENB pins
pwmENA = GPIO.PWM(ENA, 1000)  # 1000 Hz
pwmENB = GPIO.PWM(ENB, 1000)  # 1000 Hz
pwmENA.start(0)
pwmENB.start(0)

def set_speed(speed):
    pwmENA.ChangeDutyCycle(speed)
    pwmENB.ChangeDutyCycle(speed)

def move_forward():
    GPIO.output(Motor1A, GPIO.HIGH)
    GPIO.output(Motor1B, GPIO.LOW)
    GPIO.output(Motor2A, GPIO.HIGH)
    GPIO.output(Motor2B, GPIO.LOW)
    set_speed(speed)

def move_backward():
    GPIO.output(Motor1A, GPIO.LOW)
    GPIO.output(Motor1B, GPIO.HIGH)
    GPIO.output(Motor2A, GPIO.LOW)
    GPIO.output(Motor2B, GPIO.HIGH)
    set_speed(speed)

def turn_left():
    GPIO.output(Motor1A, GPIO.LOW)
    GPIO.output(Motor1B, GPIO.HIGH)
    GPIO.output(Motor2A, GPIO.HIGH)
    GPIO.output(Motor2B, GPIO.LOW)
    set_speed(turning_speed)

def turn_right():
    GPIO.output(Motor1A, GPIO.HIGH)
    GPIO.output(Motor1B, GPIO.LOW)
    GPIO.output(Motor2A, GPIO.LOW)
    GPIO.output(Motor2B, GPIO.HIGH)
    set_speed(turning_speed)

def stop():
    GPIO.output(Motor1A, GPIO.LOW)
    GPIO.output(Motor1B, GPIO.LOW)
    GPIO.output(Motor2A, GPIO.LOW)
    GPIO.output(Motor2B, GPIO.LOW)
    set_speed(0)

# Ensure cleanup is called on exit
def cleanup():
    stop()
    GPIO.cleanup()

atexit.register(cleanup)

# WebSocket connection and message handling
async def test_websocket():
    uri = "ws://192.168.1.21:8080/kinect"
    async with websockets.connect(uri) as websocket:
        while True:
            message = await websocket.recv()
            print(f"Received message: {message}")
            # Assigning gestures to robot movements
            if message == "RIGHT_HAND_OPEN LEFT_HAND_OPEN":
                move_forward()
            elif message == "RIGHT_HAND_CLOSED LEFT_HAND_CLOSED":
                move_backward()
            elif message == "RIGHT_HAND_LASSO LEFT_HAND_LASSO":
                stop()
            elif message == "RIGHT_HAND_OPEN LEFT_HAND_CLOSED":
                turn_right()
            elif message == "RIGHT_HAND_CLOSED LEFT_HAND_OPEN":
                turn_left()
            else:
                stop()

asyncio.get_event_loop().run_until_complete(test_websocket())