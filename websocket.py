# Created by: Maciej Burakowski
# Title: Alphabot2 kinect gesture control
# Date: 25/05/2024
# Description:
#   Simple app that allows to control Alphabot2 via websocket messages. 

# libraries
import asyncio
import websockets

# websocket connection START
async def test_websocket():
    uri = "ws://localhost:8080/kinect"
    async with websockets.connect(uri) as websocket:
        while True:
            message = await websocket.recv()
            print(f"Received message: {message}")

asyncio.get_event_loop().run_until_complete(test_websocket())
# websocket connection END