# Godot Websocket Client
---
This is a skeleton for a websocket client made in Godot.
Server Repository [HERE](https://github.com/ZhengYiHu/Godot-Websocket-Server)

## How to connect to the Server

Set up connection Address and Port on `res://ServerSettings.tres`.
Make sure that `Dev` option is selected according to the server's configuration.

![](https://private-user-images.githubusercontent.com/33153763/279212266-b30ecfd2-a312-46f8-b2e4-a1566a31abf4.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTEiLCJleHAiOjE2OTg3MDYyNTQsIm5iZiI6MTY5ODcwNTk1NCwicGF0aCI6Ii8zMzE1Mzc2My8yNzkyMTIyNjYtYjMwZWNmZDItYTMxMi00NmY4LWIyZTQtYTE1NjZhMzFhYmY0LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFJV05KWUFYNENTVkVINTNBJTJGMjAyMzEwMzAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjMxMDMwVDIyNDU1NFomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTBmYWYxZDUyYTZiYWMwOTk4OTljMjYyMTE3YzgwZDk2M2UwY2U2NzZlNDNlYWQ4ZmZjNDI4MWIyZDNlY2RhMmImWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0JmFjdG9yX2lkPTAma2V5X2lkPTAmcmVwb19pZD0wIn0.DrRyEndtnL6Xi07OAa4lrLAvIbIgo8dLa_8FyND-ZMQ)

`Dev = true` allows the client to bypass any SLL certificate check, which is ideal for testing, but web builds that run on browsers cannot connect to uncertified connections if you are planning on making an online web game.

If `Dev = false`, make sure that a valid certificate file is given an set in the Server Settings's field.

More information about how to obtain the SLL certificate in the [Server project](https://github.com/ZhengYiHu/Godot-Websocket-Server).

## Features

- Essential RPCs synchronization
- Movement interpolation using a world state buffer
- Lag compensation for clock synchronization
- Packets encoding to lower traffic
- Customizable tick rates
- Debug view (Press `Shift + F` to enable)

## Shared code

Godot doesn't have a good solution to handle shared codebase between Server and Client that don't belong in the same project.
What this project does is to simply copy over the `res://DataBuses` folder in the server project, that contains all data structures used while communicating with the server.

## Why websocket over UDP

The main goal of this project was to create an accessible dedicated server for web based multiplayer games and since [browser games cannot utilize UPD networks](https://gafferongames.com/post/why_cant_i_send_udp_packets_from_a_browser/), I used a websocket connection for all the packet transfers.

## Demo

You can find a game using this very setup on my game [Duck Hub](https://zyhu.itch.io/duckhub) in itch.io.