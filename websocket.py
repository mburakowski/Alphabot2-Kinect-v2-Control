# Created by: Maciej Burakowski
# Title: Alphabot2 kinect gesture control
# Date: 25/05/2024
# Description:
#   Simple app that allows to receive websocket messages.
# How to use:
# 1. Make sure that Kinect v2 is connected to your computer and works correctly and both devices are connected to the same wi-fi network.
# 2. Open Processing and run kinect_open.pde
# 3. Put your device IP in "uri" section (You can easily find your IP by Command Prompt > ipconfig > IPv4 Adress).
# 4. Program is ready to run

# libraries
import asyncio
import websockets

# websocket connection START
async def test_websocket():
    uri = "ws://192.168.1.21:8080/kinect"
    async with websockets.connect(uri) as websocket:
        while True:
            message = await websocket.recv()
            print(f"Received message: {message}")  #for debugging

asyncio.get_event_loop().run_until_complete(test_websocket())
# websocket connection END
