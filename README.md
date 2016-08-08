# VKAudioPlayer #

VKAudioPlayer allows you to listen to music from your VK profile and cache it for later playback. 

## Features ##
- Fully manage your profile: add, remove, search for new music
- Cache music for future playback 
- Written in Swift 2.2

## How to install ##

First open terminal and clone the project:
```
cd ~/Documents/
git clone http://github.com/neekeetab/VKAudioPlayer```
cd VKAudioPlayer
```
For following steps, you'll need CocoaPods installed. To install CocoaPods run this command:
```
sudo gem install cocoapods
```
When you're done, run the following command. Ensure that you're in the project directory:
```
pod install
```
OK. Now open finder go the project directory and open ```VKAudioPlayer.xcworkspace```
Note, you need to have Xcode installed. 

Choose your device from the menu, and run the project.

## Known limitations / TODO list ##
- You need an internet connection to use the app even if you have some audio cached. The reason for this is that although VKAudioPlayer stores the cache, it doesn't store the list of the chached files. 
- Settings screen isn't implemented yet.
