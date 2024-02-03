# ARMapKitDemo

## Overview
ARMapKitDemo is an iOS application that demonstrates the integration of ARKit and MapKit to display Points of Interest (POIs) in both a map view and augmented reality (AR) view. This project showcases how to use ARKit to place 3D annotations in the real world as seen through the device's camera and how to synchronize these annotations with their corresponding locations on a 2D map.

## Features
- Display map annotations on a standard 2D map using MapKit.
- Convert map annotations to 3D objects in an AR scene.
- Dynamically update AR objects based on the user's location.
- Handle user interactions with both map annotations and AR objects.
- Utilize custom views as textures for 3D models in AR.
- Prevent flickering of overlapping AR objects using unique rendering orders.

## Requirements
- iOS 13.0 or later
- Xcode 12.0 or later
- Swift 5.3 or later
- An iOS device with A9 chip or later (ARKit is not supported in the iOS Simulator)

## Installation
Clone the repository and open the project in Xcode:
```bash
git clone https://github.com/isandeepj/ARKitMapDemo.git
cd ARMapKitDemo
open ARMapKitDemo.xcodeproj
```
Run the project on a compatible iOS device through Xcode.

## Usage
Upon launching the app, you will be prompted to allow access to your location. The app needs location access to display your current position and nearby POIs on the map and in the AR view.

- Tap on any POI on the map to view its details and place a corresponding 3D object in the AR view.
- In the AR view, you can interact with the POIs by tapping on them to reveal more information or perform other actions.

## Contributing
Contributions are welcome! Please feel free to submit a pull request or open an issue for any bugs, feature requests, or improvements.

