<div align="center">
<p align="center"><img src="assets/rs-logo.png" width="400"></p> 
</div> 


# RetroShare Mobile App

RetroShare mobile client written in Flutter.

This is a Flutter frontend for the retroshare-service backend. You need to have **both working**: this frontend, and the 
retroshare-service backend.

## Features

* Create one or more Retroshare profiles.
* Create and delete one or more  both Pseudo and Signed Identities, and switch between them.
* Add friend locations using classic and Short  Retroshare invites.
* Add Friend through QR scanner/QR code.
* Create lobby chats (public and private).
* Search public chat lobbies.
* Start distant chats with identities.
* Send Image and Emoji in chat.
* Get Notification of Chat Lobby Invites.
* Flexibility to accept and deny the chat lobby invites.

## Future Plans 

* Converting retroshare service (a.k.a backend of retroshare Mobile) from  background to foreground service.
* Adding Forum support.
* Support of CI/CD.

## Installing on Local Machine:

* Download recent release of retroshare service [here](https://github.com/RetroShare/retroshare-mobile/tree/master/android/retroshare-service).
* Debug: using adb to use a retroshare-service installed on your computer:

```bash
adb reverse tcp:9092 tcp:9092
```
* Follow this [steps](https://github.com/RetroShare/retroshare-mobile/blob/master/AndroidStudio-Flutter-setup.md)  for more Info.

## Contributing
Please read [Contributing.md](https://github.com/RetroShare/retroshare-mobile/blob/master/Contribution.md) for details on our code of conduct and the process for submitting pull requests to us.
 
## Support
Join our [Retroshare](https://github.com/RetroShare/RetroShare/releases) to talk to dev/tester of this project.
