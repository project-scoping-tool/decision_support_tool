# Souther Nevada Decision Support Tool (DST)
The Decision Support Tool (DST) is a tool for planning, public works and transportation professionals to integrate health and equity into land use decisions to promote safe, walkable, bikeable, and connected communities.

## Requirements and Installation
This code was developed on a Windows 10 machine using [Visual Studio Code](https://code.visualstudio.com/).

To install the Flutter framework, install it in VS Code using the provided steps provded [here](https://docs.flutter.dev/development/tools/vs-code) and [here](https://docs.flutter.dev/get-started/editor?tab=vscode).

## Changing Flutter Version
This code was tested on Flutter 2.10.2 on the [stable channel](https://docs.flutter.dev/development/tools/sdk/releases). After installing Flutter on VS Code, do the following steps to ensure you have the correct environment versioning:
* Check if Flutter is in the **stable channel** by running the following in the terminal in VS Code:
```bash
flutter channel
``` 
* If the channel is not on **stable**, run the following in the same terminal:
```bash
flutter channel stable
flutter upgrade
```
* After changing the channel to **stable**, check your Flutter version by running:
```bash
flutter --version
```
* If your Flutter version is not 2.10.2 in the stable channel, then run the following
```bash
flutter version v2.10.2
```

## Running the Code
* Clone the repo on your machine.
* Change to the video branch:
```bash
git checkout video
```
* In VS Code, open ```decision_support_tool/flutter/decision_support_tool```.
    * This is the root of the Flutter project.
* Check to see if Flutter detects any devices on your machine (i.e. web browsers).
```bash
flutter devices
```
* For example, if you have Microsoft Edge and Google Chrome browsers on your machine, you can run one following in the terminal in VS Code in debug mode:
```bash
flutter run -d edge
flutter run -d chrome
```
**The code has been optimized in full screen mode.**


## Building the Web Package (Dart to Java Script)
To build a web package (js package), run
```bash
flutter build web
```

After the package has been built, go to ```decision_support_tool/flutter/decision_support_tool/build/web```. The contents in *web* is the js package.

For more information in building web packages, [see here.](https://docs.flutter.dev/get-started/web)
